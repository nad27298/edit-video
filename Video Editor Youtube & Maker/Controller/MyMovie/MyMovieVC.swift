//
//  MyMovieVC.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 12/24/20.
//

import UIKit
import StoreKit
import SQLite
import AVKit
import Photos
import UserNotifications

class MyMovieVC: UIViewController {
    
    var videos: [VideoModel] = []

    @IBOutlet weak var cvcMyMovie: UICollectionView!
    @IBOutlet weak var lblHelp: UILabel!
    @IBOutlet weak var lblVideo: UILabel!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var lblCreat: UILabel!
    @IBOutlet weak var lblMovie: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videos = VideoEntity.shared.getData()
        print(videos.count)
        cvcMyMovie.register(UINib(nibName: MyMovieCVC.className, bundle: nil), forCellWithReuseIdentifier: MyMovieCVC.className)
        cvcMyMovie.delegate = self
        cvcMyMovie.dataSource = self
        cvcMyMovie.reloadData()
        AdmobManager.shared.loadBannerView(inVC: self)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.sendNotification()
            default:
                break // Do nothing
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videos = VideoEntity.shared.getData()
        cvcMyMovie.reloadData()
    }
    
    @IBAction func btn_MoviePro(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let moviepro: MovieProVC = storyboard.instantiateViewController(withIdentifier: MovieProVC.className) as! MovieProVC
        self.present(moviepro, animated: true)
    }
    
    @IBAction func btn_Setting(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let setting: SettingVC = storyboard.instantiateViewController(withIdentifier: SettingVC.className) as! SettingVC
        self.present(setting, animated: true)
    }
    
    @IBAction func btn_More(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mydraft: MyDraftsVC = storyboard.instantiateViewController(withIdentifier: MyDraftsVC.className) as! MyDraftsVC
        self.present(mydraft, animated: true, completion: nil)
    }
    
    @IBAction func btn_Rate(_ sender: Any) {
        SKStoreReviewController.requestReview()
    }
    
    @IBAction func btn_Video(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let gallery: GalleryVC = storyboard.instantiateViewController(withIdentifier: GalleryVC.className) as! GalleryVC
        self.present(gallery, animated: true)
    }
    
    @IBAction func btn_Help(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let premium:HelpVC = storyboard.instantiateViewController(withIdentifier: HelpVC.className) as! HelpVC
        self.present(premium, animated: true)
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
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            (granted, error) in
            if granted {
                print("Yes")
            } else {
                print("No")
            }
        }
    }
    
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Video Me - Video Editor"
        content.body = "Edit many video if you want, check now"
        content.sound = UNNotificationSound.default
        
        // 3
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7200, repeats: true)
        
        let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
        
        // 4
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
}

extension MyMovieVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MyMovieCVC = collectionView.dequeueReusableCell(withReuseIdentifier: MyMovieCVC.className, for: indexPath) as! MyMovieCVC
        let url: URL = URL(string: videos[indexPath.row].url)!
        cell.lblTime.durationtimeVideo(url)
        cell.imgHinh.image = getThumbnailImage(forUrl: url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if PaymentManager.shared.isPurchase() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let galerryedit = storyboard.instantiateViewController(withIdentifier: GalleryEditVC.className) as! GalleryEditVC
            let url: URL = URL(string: videos[indexPath.row].url)!
            galerryedit.arrURL.append(url)
            var arrAssetPick: [AVAsset] = []
            let currentAsset = AVAsset(url: url)
            arrAssetPick.append(currentAsset)
            galerryedit.arrAsset = arrAssetPick
            if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count > 0{
                var newURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                newURL.appendPathComponent("VideoSelected.mov")
                galerryedit.urlSelectPro = newURL
                self.present(galerryedit, animated: true, completion: nil)
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

extension MyMovieVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cvcMyMovie.frame.height, height: cvcMyMovie.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
}
