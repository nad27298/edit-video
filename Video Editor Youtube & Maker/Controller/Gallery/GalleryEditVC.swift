//
//  GalleryEditVC.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 12/26/20.
//

import UIKit
import Photos
import AVKit
import CoreMedia
import AVFoundation
import MediaPlayer
import JGProgressHUD

extension Notification.Name {
    static let SEND_PHAN_TRAM = Notification.Name("SEND_PHAN_TRAM")
}

class GalleryEditVC: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, TimelinePlayStatusReceiver, SmartDelegate {
    
    // Outlet
    @IBOutlet weak var lblTimeVoice: UILabel!
    @IBOutlet weak var viewVoice: UIView!
    @IBOutlet weak var sld: UISlider!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var lblMax: UILabel!
    @IBOutlet weak var lblMin: UILabel!
    @IBOutlet weak var sldName: UILabel!
    @IBOutlet weak var viewSlider: UIView!
    @IBOutlet weak var textViewAdd: UITextView!
    @IBOutlet weak var viewText: UIView!
    @IBOutlet weak var cvcToolBar: UICollectionView!
    @IBOutlet weak var lblTotalTime: UILabel!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var cvcEditBar: UICollectionView!
    @IBOutlet weak var viewBar: UIView!
    @IBOutlet weak var viewVideos: UIView!
    @IBOutlet weak var imageButtonStart: UIImageView!
    let hudProgress = JGProgressHUD()

    
    // Audio Player
    var playerAudio: AVAudioPlayer!
    var urlAudio: URL!
    var urlMusic: URL!
    var urlVoice: URL!
    
    // ViewTimeline
    var videoTimelineView_Pro:VideoTimelineView!
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    // URL Video Player
    var urlSelectPro: URL!
    var urlFirst: URL!
    var generator:AVAssetImageGenerator!
    var imagesPick = [UIImage]()
    var arrURL: [URL] = []
    var arrAsset: [AVAsset] = []
    
    // Select index
    var selectPositon = -1
    var selectItems: Int = 100
    var selectAdjust: Int = 100
    var selectEdit: Int = 100
    var selectSticker: Int = 100
    var selectMusic: Int = 100
    var selectTools: Int = 100
    
    // Check
    var checkItems: Int = 0
    var isPlaying: Bool = false
    var typeTools = 0
    
    // CVC
    var items : [String] = []
    var stickers: [String] = []
    var tools: String = ""
    
    // Scale
    var selectToolScale = -1
    var widthScale: Int = 0
    var heighScale: Int = 0
    var transfromScale = CGAffineTransform()
    var scalecheck = true
    
    // Filter
    var filternameSelect: String = ""
    var selectToolFilter = -1
    var filterAdjust: String = ""
    
    // Effect
    var selectToolEffect = -1
    var effectnameSelect = ""
    
    // Backgound
    var selectToolBG = -1
    var backgroundView: UIImageView!
    var previewVideoView: UIView!
    var backgroundMargin: Float = 0
    var backgroundCornerRadious: Float = 0
    var backgroundColor: UIColor = UIColor.clear
    var backgroundImage: UIImage?
    var backgroundScale: CGFloat = 1
    
    // Color
    var selectToolColor = -1
    var selectedColor: UIColor = .clear
    
    // Sticker
    var selectToolSticker = -1
    var stickernameSelect = ""
    
    // Speed
    var strSelectedSpeed = ""
    var selectToolSpeed = -1
    
    // Text
    var strTextAdd = ""
    var checkText = 0
    var namevideo = "Video Save"
    
    // Transition
    var selectedTransitionType = -1
    
    // Trim
    var trimStar: Double = 0
    var trimEnd: Double = 0
    
    // Volume
    var volumeValue: Float = 0.5
    
    // Image
    var bgimagenameSelect: UIImage?
    var imagePicker = UIImagePickerController()
    var imagePick: UIImage!
    
    // Music
    var selectAudio = -1
    var selectAM = -1
    
    // Voice
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlayingVoice = false
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        if isRecording {
            viewVoice.isHidden = true
            finishAudioRecording(success: true)
            isRecording = false
        } else {
            setupRecorder()
            viewVoice.isHidden = false
            audioRecorder.record()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            isRecording = true
        }
    }
    @objc func NHAN_PHAN_TRAM_LOADING(_ notification: Notification) {
        if let loadingPro = notification.userInfo as? Float{
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        NotificationCenter.default.addObserver(self, selector: #selector(NHAN_PHAN_TRAM_LOADING(_:)), name: .SEND_PHAN_TRAM, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showViewBar()
        let color = UIColor(rgb: 0x2A303E)
        viewSlider.isHidden = true
        viewText.backgroundColor = color
        viewText.layer.cornerRadius = 20
        viewText.layer.borderWidth = 2
        viewText.layer.borderColor = #colorLiteral(red: 0.1568627451, green: 0.8352941176, blue: 0.8117647059, alpha: 1)
        viewSlider.backgroundColor = color
        viewVoice.isHidden = true
        viewText.isHidden = true
        cvcEditBar.delegate = self
        cvcEditBar.dataSource = self
        cvcToolBar.delegate = self
        cvcToolBar.dataSource = self
        cvcToolBar.reloadData()
        checkRecordPermission()
        lblCurrentTime.layer.cornerRadius = 15
        lblCurrentTime.layer.masksToBounds = true
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        imageButtonStart.addGestureRecognizer(tapGR)
        imageButtonStart.isUserInteractionEnabled = true
        
        cvcEditBar.register(UINib(nibName: GalleryEditCVC.className, bundle: nil), forCellWithReuseIdentifier: GalleryEditCVC.className)
        items = arrItems
        if arrURL.count == 0 && arrAsset.count == 0 {
            showError(message: "Error")
        } else if arrURL.count == 1 && arrAsset.count == 1 {
            urlFirst = arrURL[0]
            showViewBar()
            playVideoReload(arrURL[0])
            curruntimeVideo()
            lblTotalTime.durationtimeVideo(urlSelectPro)
        } else {
            showLoading()
            EditVideoManager().mergeMovies(videoAssets: arrAsset, success: { (url) in
                DispatchQueue.main.async {
                    self.hideLoading()
                    self.showViewBar()
                    self.playVideoReload(url)
                    self.curruntimeVideo()
                    self.lblTotalTime.durationtimeVideo(url)
                }
            }){ (error) in
                DispatchQueue.main.async {
                    self.hideLoading()
                    self.showError(message: error!.debugDescription)
                }
            }
        }
    }
    
    func updateAnswer(_ answer: String) {
        filterAdjust = answer
    }
    
    
    @IBAction func btn_Back(_ sender: Any) {
        if let videoTimelineView_Pro = videoTimelineView_Pro{
            videoTimelineView_Pro.stop()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_Save(_ sender: Any) {
        let timeStamp = Date.currentTimeStamp
        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT +7") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        namevideo = strDate
        showLoading()
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.urlSelectPro)
        }) { saved, error in
            if saved {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                    let newObj = avurlAsset as! AVURLAsset
                    let urlString: String = newObj.url.absoluteString
                    _ = VideoEntity.shared.insertName(name: self.namevideo, url: urlString, date: strDate)
                    self.hideLoading()
                    self.showSuccess(message: "Your video was successfully saved")
                })
            } else {
                DispatchQueue.main.async {
                    self.hideLoading()
                    self.showError(message: error.debugDescription)
                }
            }
        }
    }
    
    @IBAction func btn_Play(_ sender: Any) {
        isPlaying = !isPlaying
        if isPlaying == true {
            videoTimelineView_Pro.play()
        } else {
            videoTimelineView_Pro.stop()
        }
        reloadPlayVideo()
    }
    
    
    @IBAction func btn_Select(_ sender: Any) {
        videoTimelineView_Pro.stop()
        videoTimelineView_Pro.asset = nil
        videoTimelineView_Pro.removeFromSuperview()
        switch tools {
        case "Scale":
            if scalecheck == true {
                showLoading()
                EditVideoManager().cropVideo(sourceUrl: urlSelectPro, width: widthScale, height: heighScale, success: { (url) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.playerLayer.removeFromSuperlayer()
                        self.showViewBar()
                        self.playVideoReload(url)
                        self.curruntimeVideo()
                        self.scalecheck = false
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.showError(message: error!.debugDescription)
                    }
                }
            } else {
                showError(message: "Sorry, You can only scale 1 time")
            }
        case "Background":
            if bgimagenameSelect != nil {
                self.showLoading()
                EditVideoManager().addBackgroundToVideo(videoUrl: urlSelectPro, image: bgimagenameSelect, margin: 50, radious: 0, success: { (url) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.playerLayer.removeFromSuperlayer()
                        self.showViewBar()
                        self.playVideoReload(url)
                        self.curruntimeVideo()
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.showError(message: error!.debugDescription)
                    }
                }
            } else {
                showError(message: "Select background image which you want to show inside the video")
            }
        case "Color":
            self.showLoading()
            EditVideoManager().addColorToVideo(videoUrl: urlSelectPro, bgColor: selectedColor, margin: 50, radious: 0, success: { (url) in
                DispatchQueue.main.async {
                    self.hideLoading()
                    self.playerLayer.removeFromSuperlayer()
                    self.showViewBar()
                    self.playVideoReload(url)
                    self.curruntimeVideo()
                }
            }) { (error) in
                DispatchQueue.main.async {
                    self.hideLoading()
                    self.showError(message: error!.debugDescription)
                }
            }
        case "Filter":
            if filternameSelect != "" {
                self.showLoading()
                EditVideoManager().addfiltertoVideo(strfiltername: filternameSelect, strUrl: urlSelectPro, success: { (url) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.playerLayer.removeFromSuperlayer()
                        self.showViewBar()
                        self.playVideoReload(url)
                        self.curruntimeVideo()
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.showError(message: error!.debugDescription)
                    }
                }
            } else {
                showError(message: "Select filter which you want to show inside the video")
            }
        case "Effect":
            if effectnameSelect != "" {
                self.showLoading()
                EditVideoManager().addfiltertoVideo(strfiltername: effectnameSelect, strUrl: urlSelectPro, success: { (url) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.playerLayer.removeFromSuperlayer()
                        self.showViewBar()
                        self.playVideoReload(url)
                        self.curruntimeVideo()
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.showError(message: error!.debugDescription)
                    }
                }
            } else {
                showError(message: "Select effect which you want to show inside the video")
            }
        case "Image":
            if selectPositon != -1 && imagePick != nil {
                self.showLoading()
                EditVideoManager().addImagetoVideo(videoUrl: urlSelectPro, imageName: imagePick, position: selectPositon, success: { (url) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.playerLayer.removeFromSuperlayer()
                        self.showViewBar()
                        self.playVideoReload(url)
                        self.curruntimeVideo()
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.showViewBar()
                        self.showError(message: error!.debugDescription)
                    }
                }
            } else {
                showError(message: "Select position and image pick which you want to show inside the video")
            }
        case "Sticker":
            if stickernameSelect != "" && selectPositon != -1 {
                self.showLoading()
                EditVideoManager().addStickertoVideo(videoUrl: urlSelectPro, imageName: stickernameSelect, position: selectPositon, success: { (url) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        //self.videoTimelineView_Pro.asset = nil
                        self.playerLayer.removeFromSuperlayer()
                        self.showViewBar()
                        self.playVideoReload(url)
                        self.curruntimeVideo()
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.showViewBar()
                        self.showError(message: error!.debugDescription)
                    }
                }
            } else {
                showError(message: "Add image and select the position which you want to show inside the video")
            }
        case "Speed":
            if strSelectedSpeed != "" {
                showLoading()
                let num = strSelectedSpeed.toDouble()
                EditVideoManager().videoScaleAssetSpeed(fromURL: urlSelectPro, by: num ?? 1.0, success: { (url) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.playerLayer.removeFromSuperlayer()
                        self.showViewBar()
                        self.playVideoReload(url)
                        self.curruntimeVideo()
                        self.lblTotalTime.durationtimeVideo(url)
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.showError(message: error!.debugDescription)
                    }
                }
            } else {
                showError(message: "Select speed which you want to edit the video")
            }
        case "Text":
            if strTextAdd != "" && selectPositon != -1 {
                self.showLoading()
                EditVideoManager().addTexttoVideo(videoUrl: urlSelectPro, watermarkText: strTextAdd, position: selectPositon, success: { (url) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.playerLayer.removeFromSuperlayer()
                        self.showViewBar()
                        self.playVideoReload(url)
                        self.curruntimeVideo()
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.showError(message: error!.debugDescription)
                    }
                }
            } else {
                showError(message: "Add the text and select the position which you want to show inside the video")
            }
        case "Transition":
            if selectedTransitionType != -1 {
                showLoading()
                EditVideoManager().transitionAnimation(videoUrl: urlSelectPro, animation: true, type: selectedTransitionType, playerSize: self.viewVideos.frame, success: { (url) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.playerLayer.removeFromSuperlayer()
                        self.showViewBar()
                        self.playVideoReload(url)
                        self.curruntimeVideo()
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.showError(message: error!.debugDescription)
                    }
                }
            } else {
                showError(message: "Select transition which you want to edit the video")
            }
        case "Trim":
            showLoading()
            let trim = videoTimelineView_Pro.currentTrim()
            EditVideoManager().trimVideo(sourceURL: urlSelectPro, startTime:Double(trim.start), endTime: Double(trim.end), success: { (url) in
                DispatchQueue.main.async {
                    self.lblTotalTime.durationtimeVideo(url)
                    self.hideLoading()
                    self.playerLayer.removeFromSuperlayer()
                    self.showViewBar()
                    self.playVideoReload(url)
                    self.curruntimeVideo()
                }
            }){ (error) in
                DispatchQueue.main.async {
                    self.hideLoading()
                    self.showError(message: error!.debugDescription)
                }
            }
        case "Mute":
            showLoading()
            let trim = videoTimelineView_Pro.currentTrim()
            EditVideoManager().deleteAudioFromVideo(sourceURL: urlSelectPro, startTime:Double(trim.start), endTime: Double(trim.end), success: { (url) in
                DispatchQueue.main.async {
                    self.hideLoading()
                    self.playerLayer.removeFromSuperlayer()
                    self.showViewBar()
                    self.playVideoReload(url)
                    self.curruntimeVideo()
                }
            }){ (error) in
                DispatchQueue.main.async {
                    self.hideLoading()
                    self.showError(message: error!.debugDescription)
                }
            }
        case "Remove":
            showSuccess(message: "Removed")
        case "Copy":
            showSuccess(message: "Copyed")
        case "Rotate":
            showSuccess(message: "Rotated")
        case "Volumn":
            showSuccess(message: "Change volumn")
        case "Reverse":
            showSuccess(message: "Reversed")
        case "Adjust 1":
            if filterAdjust != "" {
                self.showLoading()
                EditVideoManager().addfiltertoVideo(strfiltername: filterAdjust, strUrl: urlSelectPro, success: { (url) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.playerLayer.removeFromSuperlayer()
                        self.showViewBar()
                        self.playVideoReload(url)
                        self.curruntimeVideo()
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.showError(message: error!.debugDescription)
                    }
                }
            } else {
                showError(message: "Select filter which you want to show inside the video")
            }
        case "Local":
            if urlAudio != nil {
                showLoading()
                EditVideoManager().mergeVideoWithAudio(videoUrl: urlSelectPro, audioUrl: urlAudio, success: { (url) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.playerLayer.removeFromSuperlayer()
                        self.showViewBar()
                        self.playVideoReload(url)
                        self.curruntimeVideo()
                    }
                }){ (error) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.showError(message: error!.debugDescription)
                    }
                }
            } else {
                showError(message: "Select audio if you want to add video")
            }
        case "AppleMusic":
            showLoading()
            if urlMusic != nil {
                showLoading()
                EditVideoManager().mergeVideoWithAudio(videoUrl: urlSelectPro, audioUrl: urlMusic, success: { (url) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.playerLayer.removeFromSuperlayer()
                        self.showViewBar()
                        self.playVideoReload(url)
                        self.curruntimeVideo()
                    }
                }){ (error) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.showError(message: error!.debugDescription)
                    }
                }
            } else {
                hideLoading()
                showError(message: "Can not add music to video")
            }
        case "Voiceover":
            if urlVoice != nil {
                showLoading()
                EditVideoManager().mergeVideoWithAudio(videoUrl: urlSelectPro, audioUrl: urlVoice, success: { (url) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.playerLayer.removeFromSuperlayer()
                        self.showViewBar()
                        self.playVideoReload(url)
                        self.curruntimeVideo()
                    }
                }){ (error) in
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.showError(message: error!.debugDescription)
                    }
                }
            } else {
                hideLoading()
                showError(message: "Can not add voice to video")
            }
        default:
            showError(message: "Edit Now")
        }
    }
    
    @IBAction func btn_Undo(_ sender: Any) {
        checkItems = 0
        typeTools = 0
        selectItems = 100
        viewText.isHidden = true
        viewSlider.isHidden = true
        items = arrItems
        cvcEditBar.reloadData()
    }
    
    @IBAction func btn_TextTick(_ sender: Any) {
        strTextAdd = textViewAdd.text
        viewText.isHidden = true
        self.dismissKeyboard()
    }
    
    @IBAction func btn_TextX(_ sender: Any) {
        viewText.isHidden = true
        self.dismissKeyboard()
    }
    
    @IBAction func sld_Change(_ sender: UISlider) {
        volumeValue = sld.value
        player.volume = volumeValue
        lblValue.text = String(Int(volumeValue * 100))
    }
    
}

extension GalleryEditVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cvcEditBar {
            if typeTools == 0 {
                return items.count
            } else if typeTools == 1 {
                return speedItems.count
            } else {
                return positionItems.count
            }
        } else if collectionView == cvcToolBar {
            switch tools {
            case "Scale":
                return arrScale.count
            case "Background":
                return arrBG.count
            case "Color":
                return arrColor.count
            case "Filter":
                return arrFilter.count
            case "Effect":
                return arrEffect.count
            case "Sticker":
                return stickers.count
            case "Speed":
                return speedItems.count
            case "Transition":
                return transitionItems.count
            case "Adjust 1":
                return arrAdjust1.count
            case "Local":
                return arrAudio.count
            case "AppleMusic":
                return applemusicItems?.count ?? 0
            default: break
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cvcEditBar {
            if typeTools == 0 {
                switch checkItems {
                case 0:
                    return creatCVCEditBar(selectItems, indexPath)
                case 1:
                    return creatCVCEditBar(selectAdjust, indexPath)
                case 2:
                    return creatCVCEditBar(selectEdit, indexPath)
                case 3:
                    return creatCVCEditBar(selectSticker, indexPath)
                case 4:
                    return creatCVCEditBar(selectMusic, indexPath)
                default: break
                }
            } else if typeTools == 1 {
                return creatSpeedCVC(indexPath)
            } else {
                return creatPositonCVC(indexPath)

            }
        } else if collectionView == cvcToolBar {
            switch tools {
            case "Scale":
                return creatScaleCVC(indexPath)
            case "Background":
                return creatBackgroundCVC(indexPath)
            case "Color":
                return creatColorCVC(indexPath)
            case "Filter":
                return creatFilterCVC(indexPath)
            case "Effect":
                return creatEffectCVC(indexPath)
            case "Sticker":
                return creatStickerCVC(indexPath)
            case "Transition":
                return creatTransition(indexPath)
            case "Adjust 1":
                return creatAdjustSliderCVC(indexPath)
            case "Local":
                return creatAudioCVC(indexPath)
            case "AppleMusic":
                return creatAppleMusicCVC(indexPath)
            default: break
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cvcEditBar {
            if typeTools == 0 {
                switch checkItems {
                case 0:
                    selectItems = indexPath.row
                    cvcEditBar.reloadData()
                    creatItemsView(items[indexPath.row])
                case 1:
                    selectAdjust = indexPath.row
                    cvcEditBar.reloadData()
                    creatAdjustView(items[indexPath.row])
                case 2:
                    selectEdit = indexPath.row
                    cvcEditBar.reloadData()
                    creatEditView(items[indexPath.row])
                case 3:
                    selectSticker = indexPath.row
                    cvcEditBar.reloadData()
                    creatStickerView(items[indexPath.row])
                case 4:
                    selectMusic = indexPath.row
                    cvcEditBar.reloadData()
                    creatMusicView(items[indexPath.row])
                default: break
                }
            } else if typeTools == 1 {
                scaleToSpeed(indexPath)
            } else {
                pickPosition(indexPath)
            }
        } else if collectionView == cvcToolBar {
            changeToolbar(indexPath)
        }
    }
    
}

extension GalleryEditVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cvcEditBar {
            if typeTools == 0 {
                return CGSize(width: cvcEditBar.frame.height, height: cvcEditBar.frame.height)
            } else if typeTools == 1 {
                return CGSize(width: cvcEditBar.frame.height, height: cvcEditBar.frame.height)
            } else {
                if IS_IPAD{
                    return CGSize(width: cvcEditBar.frame.width / 8 , height: cvcEditBar.frame.height)
                }else{
                    return CGSize(width: cvcEditBar.frame.width / 4 , height: cvcEditBar.frame.height)
                }
            }
        } else if collectionView == cvcToolBar {
            switch tools {
            case "Scale":
                return CGSize(width: cvcToolBar.frame.width / 4.0 - 23.5, height: cvcToolBar.frame.height / 3.0 - 8.6)
            case "Background":
                return CGSize(width: cvcToolBar.frame.height / 2.0 - 13, height: cvcToolBar.frame.height / 2 - 13)
            case "Color":
                return CGSize(width: cvcToolBar.frame.height / 2.0 - 13, height: cvcToolBar.frame.height / 2 - 13)
            case "Filter":
                return CGSize(width: cvcToolBar.frame.height / 2.0 - 3, height: cvcToolBar.frame.height / 1.5 - 17.3)
            case "Effect":
                return CGSize(width: cvcToolBar.frame.height / 2.0 - 3, height: cvcToolBar.frame.height / 1.5 - 17.3)
            case "Sticker":
                if IS_IPAD{
                    return CGSize(width: cvcToolBar.frame.height / 2.0 - 1.5, height: cvcToolBar.frame.height / 2.0 - 1.5)
                }else{
                    return CGSize(width: cvcToolBar.frame.height / 4.0 - 1.5, height: cvcToolBar.frame.height / 3.0 - 1.5)
                }
            case "Speed":
                return CGSize(width: cvcToolBar.frame.height / 4.0 - 1.5, height: cvcToolBar.frame.height / 4.0 - 1.5)
            case "Transition":
                return CGSize(width: cvcToolBar.frame.height / 2.0 - 3, height: cvcToolBar.frame.height / 1.5 - 17.3)
            case "Adjust 1":
                return CGSize(width: cvcToolBar.frame.width / 3.0 - 18, height: cvcToolBar.frame.height)
            case "Local":
                return CGSize(width: cvcToolBar.frame.height / 2.0 - 13, height: cvcToolBar.frame.height / 2 - 13)
            case "AppleMusic":
                return CGSize(width: cvcToolBar.frame.width / 2.0 - 7, height: cvcToolBar.frame.height - 26)
            default: break
            }
        }
        return CGSize()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == cvcEditBar {
            if typeTools == 0 {
                return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
            } else if typeTools == 1 {
                return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            } else {
                return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            }
        } else if collectionView == cvcToolBar {
            switch tools {
            case "Scale":
                return UIEdgeInsets(top: 53, left: 10, bottom: 53, right: 10)
            case "Background":
                return UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
            case "Color":
                return UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
            case "Filter":
                return UIEdgeInsets(top: 53, left: 40, bottom: 53, right: 40)
            case "Effect":
                return UIEdgeInsets(top: 53, left: 40, bottom: 53, right: 40)
            case "Sticker":
                return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            case "Trasition":
                return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            case "Adjust 1":
                return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            case "Local":
                return UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
            case "AppleMusic":
                return UIEdgeInsets(top: 13, left: 10, bottom: 13, right: 10)
            default: break
            }
        }
        return UIEdgeInsets()
    }
}
