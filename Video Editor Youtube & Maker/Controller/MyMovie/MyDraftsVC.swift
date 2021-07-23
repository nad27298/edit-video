//
//  MyDraftsVC.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 1/20/21.
//

import UIKit
import SQLite
import AVKit
import Photos
import DropDown
import GoogleMobileAds
import FBAudienceNetwork

class MyDraftsVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var viewText: UIView!
    @IBOutlet weak var cvcMyDraft: UICollectionView!
    @IBOutlet weak var btnSelectedAll: UIButton!
    @IBOutlet weak var btnDeleteAll: UIButton!
    @IBOutlet weak var imgDelete: UIImageView!
    @IBOutlet weak var imgTickAll: UIImageView!
    @IBOutlet weak var lblNovideo: UILabel!
    @IBOutlet weak var imgNovideo: UIImageView!
    @IBOutlet weak var btnCreat: UIButton!
    @IBOutlet weak var viewDelete: UIView!
    
    var fbNativeAds: FBNativeAd?
    var admobNativeAds: GADUnifiedNativeAd?
    var myvideos: [VideoModel] = []
    var checkDelete = false
    var checkIndex = 0
    let color = UIColor(rgb: 0x4E8B99)
    let color2 = UIColor(rgb: 0x181C27)
    var newName: String = ""
    let dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myvideos = VideoEntity.shared.getData()
        if myvideos.count == 0 {
            lblNovideo.isHidden = false
            imgNovideo.isHidden = false
            btnCreat.isHidden = false
            cvcMyDraft.isHidden = true
        } else {
            lblNovideo.isHidden = true
            imgNovideo.isHidden = true
            btnCreat.isHidden = true
            cvcMyDraft.isHidden = false
        }
        viewText.layer.cornerRadius = 20
        viewText.layer.borderWidth = 2
        viewText.layer.borderColor = #colorLiteral(red: 0.1568627451, green: 0.8352941176, blue: 0.8117647059, alpha: 1)
        cvcMyDraft.register(UINib(nibName: MyDraftCVC.className, bundle: nil), forCellWithReuseIdentifier: MyDraftCVC.className)
        cvcMyDraft.register(UINib(nibName: nativeAdmobCLVCell.className, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: nativeAdmobCLVCell.className)
        cvcMyDraft.delegate = self
        cvcMyDraft.dataSource = self
        textView.delegate = self
        textView.text = "Text here"
        textView.textColor = color
        dropDown.width = 150
        dropDown.backgroundColor = color2
        dropDown.textFont = UIFont.systemFont(ofSize: 20)
        dropDown.textColor = .white
        dropDown.textAlignment = .center
        dropDown.layer.cornerRadius = 10
        dropDown.layer.masksToBounds = true
        AdmobManager.shared.loadBannerView(inVC: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myvideos = VideoEntity.shared.getData()
        cvcMyDraft.reloadData()
        if PaymentManager.shared.isPurchase() {
            if fbNativeAds != nil{
                fbNativeAds = nil
                cvcMyDraft.reloadData()
            }
            if admobNativeAds != nil{
                admobNativeAds = nil
                cvcMyDraft.reloadData()
            }
        }else{
            if let native = AdmobManager.shared.randoomNativeAds(){
                if native is FBNativeAd{
                    fbNativeAds = native as? FBNativeAd
                    admobNativeAds = nil
                }else{
                    admobNativeAds = native as? GADUnifiedNativeAd
                    fbNativeAds = nil
                }
                cvcMyDraft.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if PaymentManager.shared.isPurchase(){
            
        } else {
            AdmobManager.shared.loadAdFull(inVC: self)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == color {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Text here"
            textView.textColor = color
        }
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_SlideMene(_ sender: Any) {
        viewDelete.isHidden = !viewDelete.isHidden
    }
    
    @IBAction func btn_Creat(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let gallery: GalleryVC = storyboard.instantiateViewController(withIdentifier: GalleryVC.className) as! GalleryVC
        self.present(gallery, animated: true)
    }
    
    @IBAction func btn_SelectAll(_ sender: Any) {
        checkDelete = !checkDelete
        setviewDelete()
        cvcMyDraft.reloadData()
    }
    
    @IBAction func btn_DeleteAll(_ sender: Any) {
        if checkDelete == true {
            _ = VideoEntity.shared.deleteAll()
            myvideos = VideoEntity.shared.getData()
            viewDelete.isHidden = true
            cvcMyDraft.reloadData()
        } else {
            showError(message: "Click SelectAll")
        }
    }
    
    func setviewDelete() {
        if checkDelete == true {
            imgTickAll.image = UIImage(named: "ClickTick")
            btnSelectedAll.setTitleColor(color, for: .normal)
            imgDelete.image = UIImage(named: "DeleteTick")
            btnDeleteAll.setTitleColor(color, for: .normal)
        } else {
            imgTickAll.image = UIImage(named: "NoTick")
            btnSelectedAll.setTitleColor(.white, for: .normal)
            imgDelete.image = UIImage(named: "Remove")
            btnDeleteAll.setTitleColor(.white, for: .normal)
        }
    }
    
    @IBAction func btn_Cancel(_ sender: Any) {
        self.dismissKeyboard()
        viewText.isHidden = true
    }
    
    @IBAction func btn_Submit(_ sender: Any) {
        newName = textView.text
        _ = VideoEntity.shared.updateName(newname: newName, id: myvideos[checkIndex].id)
        self.dismissKeyboard()
        viewText.isHidden = true
        myvideos = VideoEntity.shared.getData()
        cvcMyDraft.reloadData()
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        return nil
    }
    
}

extension MyDraftsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myvideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader{
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: nativeAdmobCLVCell.className, for: indexPath) as! nativeAdmobCLVCell
            if let native = self.admobNativeAds {
                headerView.backgroundColor = .clear
                headerView.setupHeader(nativeAd: native)
            }
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if fbNativeAds == nil && admobNativeAds == nil{
            return CGSize(width: DEVICE_WIDTH, height: 0)
        }
        return CGSize(width: DEVICE_WIDTH, height: 160 * scale)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MyDraftCVC = collectionView.dequeueReusableCell(withReuseIdentifier: MyDraftCVC.className, for: indexPath) as! MyDraftCVC
        let url: URL = URL(string: myvideos[indexPath.row].url)!
        cell.imgHinh.image = getThumbnailImage(forUrl: url)
        cell.lblTime.durationtimeVideo(url)
        cell.lblName.text = myvideos[indexPath.row].name
        cell.btnName.addTarget(self, action: #selector(btn_Name), for: .touchUpInside)
        cell.btnName.tag = indexPath.row
        cell.btnEdit.addTarget(self, action: #selector(btn_Edit), for: .touchUpInside)
        cell.btnEdit.tag = indexPath.row
        cell.imgHinh.layer.cornerRadius = 10
        if checkDelete == false {
            cell.btnName.isHidden = false
            cell.btnEdit.isHidden = false
            cell.imgTick.isHidden = true
        } else {
            cell.btnName.isHidden = true
            cell.btnEdit.isHidden = true
            cell.imgTick.isHidden = false
        }
        return cell
    }
    
    @objc func btn_Name(_ sender: UIButton) {
        checkIndex = sender.tag
        textView.text = "Text here"
        textView.textColor = color
        viewText.isHidden = false
    }
    
    @objc func btn_Edit(_ sender: UIButton) {
        let buttonPosition : CGPoint = sender.convert(sender.bounds.origin, to: view)
        dropDown.anchorView = view
        dropDown.dataSource = ["Copy", "Rename", "Delete"]
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            switch index {
            case 0:
                self.checkIndex = sender.tag
                UIPasteboard.general.string = self.myvideos[self.checkIndex].url
                self.showSuccess(message: "Copyed to clipboard")
            case 1:
                self.checkIndex = sender.tag
                self.textView.text = "Text here"
                self.textView.textColor = self.color
                self.viewText.isHidden = false
            case 2:
                self.checkIndex = sender.tag
                _ = VideoEntity.shared.delete(id: self.myvideos[self.checkIndex].id)
                self.myvideos = VideoEntity.shared.getData()
                self.cvcMyDraft.reloadData()
            default: break
            }
        }
        dropDown.bottomOffset = CGPoint(x: buttonPosition.x, y:buttonPosition.y)
        dropDown.show()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let shareyoutube: ShareYoutubeVC = storyboard.instantiateViewController(withIdentifier: ShareYoutubeVC.className) as! ShareYoutubeVC
        let url: URL = URL(string: myvideos[indexPath.row].url)!
        shareyoutube.url = url
        shareyoutube.nameVideo = myvideos[indexPath.row].name
        self.present(shareyoutube, animated: true, completion: nil)
    }
    
}

extension MyDraftsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cvcMyDraft.frame.width - 14, height: (cvcMyDraft.frame.width - 14) / 4.0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10 * scaleW, left: 5, bottom: 10 * scaleW, right: 5)
    }
}

    //MARK: -- PopMenu Exampe

//        let manager = PopMenuManager.default
//        manager.actions = [
//            PopMenuDefaultAction(title: "Copy", color: .white, didSelect: { (pop_Copy) in
//                self.checkIndex = sender.tag
//                UIPasteboard.general.string = self.myvideos[self.checkIndex].url
//                self.showSuccess(message: "Copyed to clipboard")
//            }),
//            PopMenuDefaultAction(title: "Rename", color: .white, didSelect: { (pop_Rename) in
//                self.checkIndex = sender.tag
//                self.textView.text = "Text here"
//                self.textView.textColor = self.color
//                self.viewText.isHidden = false
//            }),
//            PopMenuDefaultAction(title: "Delete", color: .white, didSelect: { (pop_Delete) in
//                self.checkIndex = sender.tag
//                _ = VideoEntity.shared.delete(id: self.myvideos[self.checkIndex].id)
//                self.myvideos = VideoEntity.shared.getData()
//                self.cvcMyDraft.reloadData()
//            })
//        ]
//        manager.present()
