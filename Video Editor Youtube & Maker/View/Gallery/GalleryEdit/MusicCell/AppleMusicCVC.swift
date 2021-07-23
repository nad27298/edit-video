//
//  AppleMusicCVC.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 1/18/21.
//

import Foundation
import UIKit
import Photos
import AVKit
import MediaPlayer
import AVFoundation

class AppleMusicCVC: UICollectionViewCell {
    
    var isPlaying = false
    var checkMusic = 0
    var playMusicC: AVAudioPlayer!
    let playQ = MPMusicPlayerController.applicationMusicPlayer

    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblArtist: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgHinh: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func btn_Play(_ sender: Any) {
//        isPlaying = !isPlaying
//        if isPlaying == true {
//            playSound()
//        } else {
//            playQ.pause()
//        }
//        reloadMusic()
    }
    
    func playSound() {
        playQ.setQueue(with: .songs())
        playQ.play()
    }
    
    
    func reloadMusic() {
        if isPlaying == true {
            btnPlay.setImage(UIImage(named: "PauseAudio"), for: .normal)
        } else {
            btnPlay.setImage(UIImage(named: "PlayAudio"), for: .normal)
        }
    }
    
}
