//
//  GalleryEditExtension.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 1/14/21.
//

import Foundation
import UIKit
import Photos
import AVKit
import MediaPlayer

extension GalleryEditVC {
    
    //MARK: -- Extension function

    
    // Video Timline
    func videoTimelineStopped() {
        isPlaying = false
        reloadPlayVideo()
    }
    
    func videoTimelineMoved() {
    }
    
    func videoTimelineTrimChanged() {
    }
    
    // Play Video
    func playVideoReload(_ url: URL) {
        urlSelectPro = url
        setVieoTimeline(urlSelectPro)
        playVideoTimeline()
        isPlaying = true
        reloadPlayVideo()
    }
    
    // Set Video
    func reloadPlayVideo() {
        if isPlaying == true {
            btnPlay.setImage(UIImage(named: "Pause"), for: .normal)
        } else {
            btnPlay.setImage(UIImage(named: "Play"), for: .normal)
        }
    }
    
    func playVideoTimeline() {
        player = videoTimelineView_Pro.player!
        if let playerLayer = playerLayer{ //giai quyet van de ve bo nho tranh memory leak crash
            playerLayer.player = player
        }else{
            playerLayer = AVPlayerLayer(player: player)
        }
        playerLayer.frame = viewVideos.bounds
        playerLayer.videoGravity = .resizeAspect
        viewVideos.layer.addSublayer(playerLayer)
        videoTimelineView_Pro.play()
    }
    
    func setVieoTimeline(_ url: URL) {
        let asset = AVAsset(url: url)
        if let videoTimelineView_Pro = videoTimelineView_Pro{
            
        }else{
            videoTimelineView_Pro = VideoTimelineView() //crash tran bo nho memory leak
        }
        videoTimelineView_Pro.frame = viewBar.bounds
        videoTimelineView_Pro.new(asset:asset)
        videoTimelineView_Pro.playStatusReceiver = self
        videoTimelineView_Pro.repeatOn = true
        videoTimelineView_Pro.setTrimIsEnabled(true)
        videoTimelineView_Pro.setTrimmerIsHidden(false)
        viewBar.addSubview(videoTimelineView_Pro)
        videoTimelineView_Pro.moveTo(0, animate:false)
        videoTimelineView_Pro.setTrim(start:0, end:asset.duration.seconds, seek:nil, animate:false)
    }
    
    func curruntimeVideo() {
        let interval = CMTime(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
            let seconds = CMTimeGetSeconds(progressTime)
            let secondString = String(format: "%02d", Int(seconds) % 60)
            let minutString = String(format: "%02d", Int(seconds) / 60)
            self.lblCurrentTime.text = "\(minutString):\(secondString)"
        })
    }
    
    // View
    func showViewBar () {
        viewBar.isHidden = false
        cvcToolBar.isHidden = true
    }
    
    func showToolCVC() {
        viewBar.isHidden = true
        cvcToolBar.isHidden = false
    }
    
    // Audio
    func playSound(_ urlSound: String) {
        guard let url = Bundle.main.url(forResource: urlSound, withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            playerAudio = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let playerAudio = playerAudio else { return }
            playerAudio.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // Voice
    func checkRecordPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        default:
            break
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getAudioURL() -> URL {
        let filename = "myRecording.m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    
    func setupRecorder() {
        if isAudioRecordingGranted {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: getAudioURL(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
            } catch let error {
                displayAlert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }
        } else {
            displayAlert(msg_title: "Error", msg_desc: "Don't have access to use your microphone.", action_title: "OK")
        }
    }
    
    @objc func updateAudioMeter(timer: Timer) {
        if audioRecorder.isRecording {
            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            lblTimeVoice.text = totalTimeString
            audioRecorder.updateMeters()
        }
    }
    
    func finishAudioRecording(success: Bool) {
        if success {
            audioRecorder.stop()
            audioRecorder = nil
            urlVoice = getAudioURL()
            meterTimer.invalidate()
            print("recorded successfully.")
        } else {
            displayAlert(msg_title: "Error", msg_desc: "Recording failed.", action_title: "OK")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishAudioRecording(success: false)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //        record_btn_ref.isEnabled = true
    }
    
    func displayAlert(msg_title : String , msg_desc : String ,action_title : String) {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default) {
            (result : UIAlertAction) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
    
    func preparePlay(){
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getAudioURL())
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        } catch {
            print("Error")
        }
    }
    
    //MARK: -- Creat Cell in CollectionViewCell
    
    
    // Items Cell
    func creatPositonCVC(_ indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GalleryTypeCVC = cvcEditBar.dequeueReusableCell(withReuseIdentifier: GalleryTypeCVC.className, for: indexPath) as! GalleryTypeCVC
        cell.lblItems.text = positionItems[indexPath.row]
        cell.lblItems.font = UIFont.systemFont(ofSize: 15) 
        if selectPositon == indexPath.row {
            cell.lblItems.textColor = .black
            cell.backgroundColor = .white
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
        } else {
            cell.lblItems.textColor = .white
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    func creatCVCEditBar(_ check: Int,_ indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GalleryEditCVC = cvcEditBar.dequeueReusableCell(withReuseIdentifier: GalleryEditCVC.className, for: indexPath) as! GalleryEditCVC
        cell.imgItems.image = UIImage(named: items[indexPath.row])
        cell.lblItems.text = items[indexPath.row]
        if check == indexPath.row {
            cell.lblItems.textColor = .white
        } else {
            cell.lblItems.textColor = .lightGray
        }
        return cell
    }
    
    func creatFilterCVC(_ indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FilterCVC = cvcToolBar.dequeueReusableCell(withReuseIdentifier: FilterCVC.className, for: indexPath) as! FilterCVC
        cell.lblName.text = arrFilter[indexPath.row]
        cell.imgHinh.image = UIImage.init(named: arrFilter[indexPath.row].replacingOccurrences(of: " ", with: ""))
        if selectToolFilter == indexPath.row {
            cell.backgroundColor = .lightGray
            cell.layer.cornerRadius = 10
        } else {
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    func creatEffectCVC(_ indexPath: IndexPath) -> UICollectionViewCell {
        let cell: EffectCVC = cvcToolBar.dequeueReusableCell(withReuseIdentifier: EffectCVC.className, for: indexPath) as! EffectCVC
        cell.imgHinh.image = UIImage(named: arrEffect[indexPath.row])
        cell.lblName.text = arrEffect[indexPath.row]
        if selectToolEffect == indexPath.row {
            cell.backgroundColor = .lightGray
            cell.layer.cornerRadius = 10
        } else {
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    func creatTransition(_ indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TransitionCVC = cvcToolBar.dequeueReusableCell(withReuseIdentifier: TransitionCVC.className, for: indexPath) as! TransitionCVC
        cell.lblName.text = transitionItems[indexPath.row]
        if selectedTransitionType == indexPath.row {
            cell.lblName.textColor = .black
            cell.backgroundColor = .white
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
        } else {
            cell.lblName.textColor = .white
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    // Sticker Cell
    func creatStickerCVC(_ indexPath: IndexPath) -> UICollectionViewCell {
        let cell: StickerCVC = cvcToolBar.dequeueReusableCell(withReuseIdentifier: StickerCVC.className, for: indexPath) as! StickerCVC
        cell.imgHinh.image = UIImage(named: stickers[indexPath.row])
        if selectToolSticker == indexPath.row {
            cell.backgroundColor = .lightGray
            cell.layer.cornerRadius = 5
        } else {
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    // Adjust Cell
    func creatScaleCVC(_ indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ScaleCVC = cvcToolBar.dequeueReusableCell(withReuseIdentifier: ScaleCVC.className, for: indexPath) as! ScaleCVC
        cell.imgHinh.image = UIImage(named: arrScale[indexPath.row])
        cell.lblName.text = arrScaleName[indexPath.row]
        if selectToolScale == indexPath.row {
            cell.backgroundColor = .lightGray
            cell.layer.cornerRadius = 10
        } else {
            cell.backgroundColor = .clear
        }
        return cell
    }
    func creatBackgroundCVC(_ indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BackgroundCVC = cvcToolBar.dequeueReusableCell(withReuseIdentifier: BackgroundCVC.className, for: indexPath) as! BackgroundCVC
        cell.imgHinh.image = UIImage(named: arrBG[indexPath.row])
        cell.imgHinh.layer.cornerRadius = 20
        if selectToolBG == indexPath.row {
            cell.backgroundColor = .lightGray
            cell.layer.cornerRadius = 15
        } else {
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    func creatColorCVC(_ indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ColorCVC = cvcToolBar.dequeueReusableCell(withReuseIdentifier: ColorCVC.className, for: indexPath) as! ColorCVC
        cell.viewColor.backgroundColor = arrColor[indexPath.row]
        cell.viewColor.layer.cornerRadius = 20
        if selectToolColor == indexPath.row {
            cell.backgroundColor = .lightGray
            cell.layer.cornerRadius = 15
        } else {
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    func creatAdjustSliderCVC(_ indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AdjustSliderCVC = cvcToolBar.dequeueReusableCell(withReuseIdentifier: AdjustSliderCVC.className, for: indexPath) as! AdjustSliderCVC
        cell.lblName.text = arrAdjust1[indexPath.row]
        cell.imgHinh.image = UIImage(named: arrAdjust1[indexPath.row])
        cell.delegate = self
        cell.checkSld = indexPath.row
        return cell
    }
    
    // Edit Cell
    func creatSpeedCVC(_ indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SpeedCVC = cvcEditBar.dequeueReusableCell(withReuseIdentifier: SpeedCVC.className, for: indexPath) as! SpeedCVC
        cell.lblName.text = speedItems[indexPath.row]
        if selectToolSpeed == indexPath.row {
            cell.backgroundColor = .lightGray
            cell.layer.cornerRadius = 5
        } else {
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    // Music Cell
    func creatAudioCVC(_ indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AudioCVC = cvcToolBar.dequeueReusableCell(withReuseIdentifier: AudioCVC.className, for: indexPath) as! AudioCVC
        cell.checkAudio = indexPath.row
        cell.lblName.text = arrAudio[indexPath.row]
        cell.layer.cornerRadius = 20
        if selectAudio == indexPath.row {
            cell.backgroundColor = .white
            cell.lblName.textColor = .black
        } else {
            cell.backgroundColor = .clear
            cell.lblName.textColor = .white
        }
        return cell
    }
    
    func creatAppleMusicCVC(_ indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AppleMusicCVC = cvcToolBar.dequeueReusableCell(withReuseIdentifier: AppleMusicCVC.className, for: indexPath) as! AppleMusicCVC
        cell.checkMusic = indexPath.row
        cell.lblName.text = applemusicItems?[indexPath.row].title
        cell.lblArtist.text = applemusicItems?[indexPath.row].artist
        cell.btnPlay.isHidden = true
        cell.layer.cornerRadius = 20
        if selectAM == indexPath.row {
            cell.backgroundColor = .white
            cell.lblName.textColor = .black
        } else {
            cell.backgroundColor = .clear
            cell.lblName.textColor = .white
        }
        return cell
    }
    
    //MARK: -- Did Select Cell in CollectionViewCell
    
    
    // Select in Edit Cell
    func pickPosition(_ indexPath: IndexPath) {
        selectPositon = indexPath.row
        cvcEditBar.reloadData()
    }
    
    func creatItemsView(_ type: String) {
        tools = type
        switch type {
        case "Adjust":
            tools = "Scale"
            checkItems = 1
            items = arrAdjust
            cvcEditBar.reloadData()
            showToolCVC()
            cvcToolBar.register(UINib(nibName: ScaleCVC.className, bundle: nil), forCellWithReuseIdentifier: ScaleCVC.className)
            cvcToolBar.reloadData()
        case "Edit":
            checkItems = 2
            items = arrEdit
            showViewBar()
            cvcEditBar.reloadData()
        case "Filter":
            showToolCVC()
            cvcToolBar.register(UINib(nibName: FilterCVC.className, bundle: nil), forCellWithReuseIdentifier: FilterCVC.className)
            cvcToolBar.reloadData()
        case "Effect":
            showToolCVC()
            cvcToolBar.register(UINib(nibName: EffectCVC.className, bundle: nil), forCellWithReuseIdentifier: EffectCVC.className)
            cvcToolBar.reloadData()
        case "Sticker":
            checkItems = 3
            items = arrSticker
            showToolCVC()
            cvcEditBar.reloadData()
            cvcToolBar.register(UINib(nibName: StickerCVC.className, bundle: nil), forCellWithReuseIdentifier: StickerCVC.className)
            cvcToolBar.reloadData()
        case "Text":
            viewText.isHidden = false
            typeTools = 2
            viewBar.isHidden = true
            cvcToolBar.isHidden = true
            cvcEditBar.register(UINib(nibName: GalleryTypeCVC.className, bundle: nil), forCellWithReuseIdentifier: GalleryTypeCVC.className)
            cvcEditBar.reloadData()
        case "Transition":
            showToolCVC()
            cvcToolBar.register(UINib(nibName: TransitionCVC.className, bundle: nil), forCellWithReuseIdentifier: TransitionCVC.className)
            cvcToolBar.reloadData()
        case "Music":
            checkItems = 4
            items = arrMusic
            cvcEditBar.reloadData()
        default: break
        }
    }
    func creatAdjustView(_ type : String) {
        tools = type
        switch type {
        case "Scale":
            showToolCVC()
            cvcToolBar.register(UINib(nibName: ScaleCVC.className, bundle: nil), forCellWithReuseIdentifier: ScaleCVC.className)
            cvcToolBar.reloadData()
        case "Background":
            showToolCVC()
            cvcToolBar.register(UINib(nibName: BackgroundCVC.className, bundle: nil), forCellWithReuseIdentifier: BackgroundCVC.className)
            cvcToolBar.reloadData()
        case "Color":
            showToolCVC()
            cvcToolBar.register(UINib(nibName: ColorCVC.className, bundle: nil), forCellWithReuseIdentifier: ColorCVC.className)
            cvcToolBar.reloadData()
        case "Adjust 1":
            showToolCVC()
            cvcToolBar.register(UINib(nibName: AdjustSliderCVC.className, bundle: nil), forCellWithReuseIdentifier: AdjustSliderCVC.className)
            cvcToolBar.reloadData()
        default: break
        }
    }
    func creatEditView(_ type: String) {
        tools = type
        switch type {
        case "Remove":
            let alert: UIAlertController = UIAlertController(title: "Do you want remove this video?", message: "", preferredStyle: .alert)
            let btn_Ok: UIAlertAction = UIAlertAction(title: "OK", style: .default) { (btnOk) in
                self.videoTimelineView_Pro.stop()
                self.showViewBar()
                self.urlSelectPro = self.urlFirst
                self.playerLayer.removeFromSuperlayer()
                if let abc = self.urlSelectPro{
                    self.playVideoReload(abc)//crash
                    self.curruntimeVideo()
                }
                
            }
            let btn_Cancel: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(btn_Ok)
            alert.addAction(btn_Cancel)
            self.present(alert, animated: true, completion: nil)
        case "Speed":
            typeTools = 1
            cvcEditBar.register(UINib(nibName: SpeedCVC.className, bundle: nil), forCellWithReuseIdentifier: SpeedCVC.className)
            cvcEditBar.reloadData()
        case "Trim":
            viewBar.isHidden = false
            cvcToolBar.isHidden = true
            showSuccess(message: "Scale timeline value to trim video")
        case "Mute":
            player.isMuted = true
        case "Volumn":
            player.isMuted = false
            viewSlider.isHidden = false
            viewBar.isHidden = true
            cvcToolBar.isHidden = true
        case "Reverse":
            videoTimelineView_Pro.stop()
            videoTimelineView_Pro.removeFromSuperview()
            showLoading()
            VideoGenerator.current.reverseVideo(fromVideo: urlSelectPro) { (result) in
                switch result {
                case .success(let url):
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.playerLayer.removeFromSuperlayer()
                        self.urlSelectPro = url
                        self.playVideoReload(self.urlSelectPro)
                        self.curruntimeVideo()
                    }
                case .failure(let error):
                    self.hideLoading()
                    self.showError(message: error.localizedDescription)
                }
            }
        case "Rotate":
            videoTimelineView_Pro.stop()
            videoTimelineView_Pro.removeFromSuperview()
            showLoading()
            EditVideoManager().rotateVideo(sourceUrl: urlSelectPro, success: { (url) in
                DispatchQueue.main.async {
                    self.hideLoading()
                    self.playerLayer.removeFromSuperlayer()
                    self.urlSelectPro = url
                    self.playVideoReload(self.urlSelectPro)
                    self.curruntimeVideo()
                }
            }) { (error) in
                DispatchQueue.main.sync {
                    self.hideLoading()
                    self.showError(message: error!.debugDescription)
                }
            }
        case "Copy":
            videoTimelineView_Pro.stop()
            videoTimelineView_Pro.removeFromSuperview()
            showMessage("Copying")
            EditVideoManager().copyVideo(from: urlSelectPro, success: { (url) in
                DispatchQueue.main.async {
                    self.hideLoading()
                    self.playerLayer.removeFromSuperlayer()
                    self.urlSelectPro = url
                    self.playVideoReload(self.urlSelectPro)
                }
            }) { (error) in//crash
                DispatchQueue.main.sync {
                    self.hideLoading()
                    self.showError(message: error!.debugDescription)
                }
            }
        default: break
        }
    }
    func creatStickerView(_ type: String) {
        tools = "Sticker"
        switch type {
        case "Image":
            tools = "Image"
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
            stickers = arrImage
            cvcToolBar.reloadData()
        case "Gif":
            stickers = arrGif
            cvcToolBar.reloadData()
        case "Emoji":
            stickers = arrEmoji
            cvcToolBar.reloadData()
        case "Cmoji":
            stickers = arrCmoji
            cvcToolBar.reloadData()
        case "Boom":
            stickers = arrBoom
            cvcToolBar.reloadData()
        case "Socks":
            stickers = arrSocks
            cvcToolBar.reloadData()
        case "ABC":
            stickers = arrABC
            cvcToolBar.reloadData()
        case "NewYear":
            stickers = arrNewYear
            cvcToolBar.reloadData()
        case "Santa":
            stickers = arrSanta
            cvcToolBar.reloadData()
        case "Love":
            stickers = arrLove
            cvcToolBar.reloadData()
        case "Rainbow":
            stickers = arrRainbow
            cvcToolBar.reloadData()
        case "Social":
            stickers = arrSocial
            cvcToolBar.reloadData()
        case "Ghost":
            stickers = arrGhost
            cvcToolBar.reloadData()
        case "Light":
            stickers = arrLight
            cvcToolBar.reloadData()
        case "ThugLife":
            stickers = arrThugLife
            cvcToolBar.reloadData()
        case "Fire":
            stickers = arrFire
            cvcToolBar.reloadData()
        case "Icon":
            stickers = arrIcon
            cvcToolBar.reloadData()
        default: break
        }
    }
    func creatMusicView(_ type: String) {
        tools = type
        switch type {
        case "Local":
            showToolCVC()
            cvcToolBar.register(UINib(nibName: AudioCVC.className, bundle: nil), forCellWithReuseIdentifier: AudioCVC.className)
            cvcToolBar.reloadData()
        case "AppleMusic":
            showToolCVC()
            cvcToolBar.register(UINib(nibName: AppleMusicCVC.className, bundle: nil), forCellWithReuseIdentifier: AppleMusicCVC.className)
            cvcToolBar.reloadData()
        case "Voiceover":
            videoTimelineView_Pro.stop()
            cvcToolBar.isHidden = true
            viewBar.isHidden = true
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
        default: break
        }
    }
    
    // Select in Tools Cell
    func changeToolbar(_ indexPath: IndexPath) {
        switch tools {
        case "Scale":
            changeScale(indexPath)
        case "Background":
            setBackground(indexPath)
        case "Color":
            setColor(indexPath)
        case "Filter":
            changeFilter(indexPath)
        case "Effect":
            changeEffect(indexPath)
        case "Sticker":
            addSticker(indexPath)
        case "Transition":
            animatedTransition(indexPath)
        case "Local":
            selectedAudio(indexPath)
        case "AppleMusic":
            seletedMusic(indexPath)
        default: break
        }
    }
    
    func changeScale(_ indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            heighScale = 0
            widthScale = 0
        case 1:
            heighScale = 1
            widthScale = 1
        case 2:
            widthScale = 4
            heighScale = 5
        case 3:
            widthScale = 16
            heighScale = 9
        case 4:
            widthScale = 9
            heighScale = 16
        case 5:
            widthScale = 4
            heighScale = 3
        default: break
        }
        selectToolScale = indexPath.row
        cvcToolBar.reloadData()
    }
    
    func setBackground(_ indexPath: IndexPath) {
        selectToolBG = indexPath.row
        bgimagenameSelect = UIImage(named: arrBG[indexPath.row])
        cvcToolBar.reloadData()
    }
    
    func setColor(_ indexPath: IndexPath) {
        selectToolColor = indexPath.row
        selectedColor = arrColor[indexPath.row]
        cvcToolBar.reloadData()
    }
    
    func changeFilter(_ indexPath: IndexPath) {
        selectToolFilter = indexPath.row
        filternameSelect = CIFilterNames[indexPath.row]
        cvcToolBar.reloadData()
    }
    
    func changeEffect(_ indexPath: IndexPath) {
        selectToolEffect = indexPath.row
        effectnameSelect = CIEffectNames[indexPath.row]
        cvcToolBar.reloadData()
    }
    
    func addSticker(_ indexPath: IndexPath) {
        selectToolSticker = indexPath.row
        stickernameSelect = stickers[indexPath.row]
        cvcToolBar.reloadData()
        typeTools = 2
        cvcEditBar.register(UINib(nibName: GalleryTypeCVC.className, bundle: nil), forCellWithReuseIdentifier: GalleryTypeCVC.className)
        cvcEditBar.reloadData()
    }
    
    func scaleToSpeed(_ indexPath: IndexPath) {
        strSelectedSpeed = speedItems[indexPath.row]
        selectToolSpeed = indexPath.row
        cvcEditBar.reloadData()
    }
    
    func animatedTransition(_ indexPath: IndexPath) {
        selectedTransitionType = indexPath.row
        cvcToolBar.reloadData()
    }
    
    func selectedAudio(_ indexPath: IndexPath) {
        selectAudio = indexPath.row
        urlAudio = Bundle.main.url(forResource: arrAudio[indexPath.row], withExtension: "mp3")
        cvcToolBar.reloadData()
    }
    
    func seletedMusic(_ indexPath: IndexPath) {
        selectAM = indexPath.row
        if let urlAM = applemusicItems?[indexPath.row].assetURL {
            self.urlMusic = urlAM
        }
        cvcToolBar.reloadData()
    }
    
}

extension GalleryEditVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePick = image
        }
        typeTools = 2
        cvcEditBar.register(UINib(nibName: GalleryTypeCVC.className, bundle: nil), forCellWithReuseIdentifier: GalleryTypeCVC.className)
        cvcEditBar.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
}
