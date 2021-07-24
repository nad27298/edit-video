//
//  GalleryVC.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 12/25/20.
//

import UIKit
import Photos
import AVKit
import ESPullToRefresh

class GalleryVC: UIViewController {
    
    @IBOutlet weak var cvcGalleryBar: UICollectionView!
    @IBOutlet weak var viewBar: UIView!
    @IBOutlet weak var cvcGallery: UICollectionView!
    @IBOutlet weak var btnPhoto: UIButton!
    @IBOutlet weak var btnVideo: UIButton!
    @IBOutlet weak var btnScreenshot: UIButton!
    @IBOutlet weak var lblName: UILabel!

    var LinkImageVideo = [URL]()
    var imagesPick = [UIImage]()
    var arrURLPick: [URL] = []
    var arrAssetPick: [AVAsset] = []
    var indexNow = 0
    var gameTimer: Timer?
    var proIndex = 0
    var checkCu = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        cvcGallery.delegate = self
        cvcGallery.dataSource = self
        cvcGalleryBar.delegate = self
        cvcGalleryBar.dataSource = self
        cvcGallery.backgroundColor = .clear
        cvcGalleryBar.backgroundColor = .clear
        viewBar.layer.cornerRadius = 20
        cvcGallery.register(UINib(nibName: GalleryCVC.className, bundle: nil), forCellWithReuseIdentifier: GalleryCVC.className)
        cvcGalleryBar.register(UINib(nibName: GalleryBarCVC.className, bundle: nil), forCellWithReuseIdentifier: GalleryBarCVC.className)
    }
    var checklan2 = 0
    @objc func runTimedCode(){
        if self.checkCu != proIndex{
            self.checkCu = proIndex
        }else{
            checklan2 = checklan2 + 1
        }
        if checklan2 > 3{
            hideLoading()
            cvcGallery.reloadData()
            gameTimer?.invalidate()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.LinkImageVideo.removeAll()
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        PhotoLibraryManager.shared.authorize(fromViewController: self) { [weak self] (authorized) in
            self?.getVideos()
            self?.cvcGallery.reloadData()
        }
        proIndex = 0
        indexNow = 0
        viewBar.isHidden = true
        switch check {
        case 0:
            changeColor(.white, .lightGray, .lightGray)
        case 1:
            changeColor(.lightGray, .white, .lightGray)
        case 2:
            changeColor(.lightGray, .lightGray, .white)
        default:
            print("Nothing")
        }
    }
    
    func getVideos() {
        showLoading()
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d ", PHAssetMediaType.video.rawValue )
        let results = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        results.enumerateObjects { (asset, index, bool) in
            let imageManager = PHCachingImageManager()
            imageManager.requestAVAsset(forVideo: asset, options: nil, resultHandler: { (asset, audioMix, info) in
                print(self.proIndex)
                if asset != nil {
                    if  let avasset = asset as? AVURLAsset{
                        let urlVideo = avasset.url
                        DispatchQueue.main.async {
                            self.LinkImageVideo.append(urlVideo)
                        }
                    }
                    self.proIndex = self.proIndex + 1
                    if self.proIndex % 200 == 0{
                        DispatchQueue.main.async {
                            self.cvcGallery.reloadData()
                        }
                    }
                    if self.indexNow == self.proIndex{
                        DispatchQueue.main.async {
                            self.cvcGallery.reloadData()
                        }
                    }
                }
            })
            self.indexNow =  self.indexNow + 1
            self.cvcGallery.reloadData()
        }
    }
    var checkpro = 0
        
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        checkpro = checkpro + 1
        print("SONPRO______" + String(checkpro) + "___" + String(self.LinkImageVideo.count ))
        DispatchQueue.main.async {
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbNailImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbNailImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }

    
    /*
    func getPhotos() {
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if results.count > 0 {
            for i in 0..<results.count {
                let asset = results.object(at: i)
                let avasset = asset as! AVURLAsset
                let urlVideo = avasset.url
                self.LinkImageVideo.append(urlVideo)
            }
            self.cvcGallery.reloadData()
        } else {
            showError(message: "There are no photos in the gallery")
        }
    }
    
    func getScreenshoot () {
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "(mediaSubtype & %d) != 0", PHAssetMediaSubtype.photoScreenshot.rawValue)
        let results = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if results.count > 0 {
            for i in 0..<results.count {
                let asset = results.object(at: i)
                let avasset = asset as! AVURLAsset
                let urlVideo = avasset.url
                self.LinkImageVideo.append(urlVideo)
            }
            self.cvcGallery.reloadData()
        } else {
            showError(message: "There are no sreenshoots in the gallery")
        }
    }
    */
    
    @IBAction func btn_Back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func changeColor(_ video: UIColor,_ photo: UIColor,_ screenshot: UIColor) {
        btnVideo.setTitleColor(video, for: .normal)
        btnPhoto.setTitleColor(photo, for: .normal)
        btnScreenshot.setTitleColor(screenshot, for: .normal)
    }
    
    @IBAction func btn_Video(_ sender: Any) {
        check = 0
        changeColor(.white, .lightGray, .lightGray)
        LinkImageVideo.removeAll()
        getVideos()
    }
    
    @IBAction func btn_Photo(_ sender: Any) {
        check = 1
        changeColor(.lightGray, .white, .lightGray)
        LinkImageVideo.removeAll()
//        getPhotos()
    }
    
    @IBAction func btn_Screenshot(_ sender: Any) {
        check = 2
        changeColor(.lightGray, .lightGray, .white)
        LinkImageVideo.removeAll()
//        getScreenshoot()
    }
    
    @IBAction func btn_Next(_ sender: Any) {
        if PaymentManager.shared.isPurchase() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let galleryedit: GalleryEditVC = storyboard.instantiateViewController(withIdentifier: GalleryEditVC.className) as! GalleryEditVC
            if LinkImageVideo.count > 0 {
                galleryedit.arrURL = arrURLPick
                galleryedit.arrAsset = arrAssetPick
                if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count > 0{
                    var newURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    newURL.appendPathComponent("VideoSelected.mov")
                    galleryedit.urlSelectPro = newURL
                    self.present(galleryedit, animated: true)
                }
            } else {
                self.showError(message: "Select video to edit")
            }
        } else {
            DispatchQueue.main.async {
                let premium = self.storyboard?.instantiateViewController(withIdentifier: PremiumVC.className) as! PremiumVC
                premium.modalPresentationStyle = .fullScreen
                self.present(premium, animated: true, completion: nil)
            }
        }
    }
    
    
}

extension GalleryVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cvcGallery {
            return LinkImageVideo.count
        } else if collectionView == cvcGalleryBar {
            return imagesPick.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell? = nil
        if collectionView == cvcGallery {
            let cell: GalleryCVC = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCVC.className, for: indexPath) as! GalleryCVC
            self.getThumbnailImageFromVideoUrl(url: LinkImageVideo[indexPath.row], completion: { (image:UIImage?) in
                cell.backgroundColor = .clear
                cell.imgHinh.image = image
                cell.lblTime.isHidden = true
                cell.imgHinh.layer.cornerRadius = 10
                if check == 0 && self.LinkImageVideo.count > 0 {
                    cell.lblTime.isHidden = false
                    cell.lblTime.durationtimeVideo(self.LinkImageVideo[indexPath.row])
                }
            })
            return cell
        } else if collectionView == cvcGalleryBar {
            let cell: GalleryBarCVC = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryBarCVC.className, for: indexPath) as! GalleryBarCVC
            cell.backgroundColor = .clear
            cell.btnDelete.tag = indexPath.row
            cell.btnDelete.addTarget(self, action: #selector(btn_Delete), for: .touchUpInside)
            cell.imgHinh.layer.cornerRadius = 10
            cell.imgHinh.image = imagesPick[indexPath.row]
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            return cell
        } else {
            return cell!
        }
    }
    
    @objc func btn_Delete(_ sender: UIButton) {
        let i = sender.tag
        imagesPick.remove(at: i)
        if check == 0 && LinkImageVideo.count > 0 {
            arrURLPick.remove(at: i)
            arrAssetPick.remove(at: i)
        }
        cvcGalleryBar.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cvcGallery {
            if viewBar.isHidden == true {
                var frame = viewBar.frame
                frame.origin.y = DEVICE_HEIGHT
                viewBar.frame = frame
            }
            viewBar.isHidden = false
            UIView.animate(withDuration: 0.5) {
                var frame = self.viewBar.frame
                frame.origin.y = DEVICE_HEIGHT - frame.size.height
                self.viewBar.frame = frame
            }
            cvcGalleryBar.reloadData()
            if check == 0 && LinkImageVideo.count > 0 {
                arrURLPick.append(LinkImageVideo[indexPath.row])
                self.getThumbnailImageFromVideoUrl(url: LinkImageVideo[indexPath.row], completion: { (image:UIImage?) in
                    if let image = image{
                        self.imagesPick.append(image)
                        let currentAsset = AVAsset(url: self.LinkImageVideo[indexPath.row])
                        self.arrAssetPick.append(currentAsset)
                        self.cvcGalleryBar.reloadData()
                    }
                })
            }
        }
    }
    
}

extension GalleryVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cvcGallery {
            if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad){
                return CGSize(width: cvcGallery.frame.width / 6.0 + 40, height: cvcGallery.frame.width / 6.0 - 10 )
             }
             else{
                return CGSize(width: cvcGallery.frame.width / 3.0 + 40 , height: cvcGallery.frame.width / 3.0 - 10)
             }
        } else {
            return CGSize(width: cvcGalleryBar.frame.height, height: cvcGalleryBar.frame.height)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == cvcGallery {
            return UIEdgeInsets(top: 10, left: 9, bottom: 10, right: 9)
        } else {
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
}
