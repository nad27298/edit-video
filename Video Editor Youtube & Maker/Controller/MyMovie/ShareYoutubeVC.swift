//
//  ShareYoutubeVC.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 1/21/21.
//

import UIKit
import AVKit

class ShareYoutubeVC: UIViewController {
    
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblTotaltime: UILabel!
    @IBOutlet weak var lblCurrentTime: UILabel!
    
    var url: URL!
    var nameVideo: String = ""
    var isPlaying = true
    
    fileprivate var player: AVPlayer? {
        didSet { player?.play() }
    }

    fileprivate var playerObserver: Any?
    
    deinit {
        guard let observer = playerObserver else { return }
        NotificationCenter.default.removeObserver(observer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(url!)
        lblCurrentTime.layer.cornerRadius = 15
        lblCurrentTime.layer.masksToBounds = true
        lblName.text = nameVideo
        lblTotaltime.durationtimeVideo(url)
        let playerLayer = videoPlayerLayer(url)
        playerLayer.frame = viewVideo.bounds
        viewVideo.layer.addSublayer(playerLayer)
        curruntimeVideo()
        isPlaying = true
        reloadPlayVideo()
        AdmobManager.shared.loadBannerView(inVC: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if PaymentManager.shared.isPurchase(){
            
        } else {
            AdmobManager.shared.loadAdFull(inVC: self)
        }
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        player?.pause()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_Play(_ sender: Any) {
        isPlaying = !isPlaying
        if isPlaying == true {
            player?.play()
        } else {
            player?.pause()
        }
        reloadPlayVideo()
    }
    
    @IBAction func btn_Share(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "Sorry", message: "This feature will be available in upcoming versions soon", preferredStyle: .alert)
        let btnOk: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(btnOk)
        self.present(alert, animated: true, completion: nil)
    }
    
    func curruntimeVideo() {
        let interval = CMTime(value: 1, timescale: 2)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
            let seconds = CMTimeGetSeconds(progressTime)
            let secondString = String(format: "%02d", Int(seconds) % 60)
            let minutString = String(format: "%02d", Int(seconds) / 60)
            self.lblCurrentTime.text = "\(minutString):\(secondString)"
        })
    }
    
    func reloadPlayVideo() {
        if isPlaying == true {
            btnPlay.setImage(UIImage(named: "Pause"), for: .normal)
        } else {
            btnPlay.setImage(UIImage(named: "Play"), for: .normal)
        }
    }
    
    func videoPlayerLayer(_ url: URL) -> AVPlayerLayer {
        let player = AVPlayer(url: url)
        let resetPlayer = {
            player.seek(to: CMTime.zero)
            player.play()
        }
        playerObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { notification in
            resetPlayer()
        }
        self.player = player
        return AVPlayerLayer(player: player)
    }
    
}
