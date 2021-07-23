//
//  AudioCVC.swift
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

class AudioCVC: UICollectionViewCell {

    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgHinh: UIImageView!
    
    var checkAudio: Int = 0
    var playerAudioC: AVAudioPlayer!
    var isPlaying = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    @IBAction func btn_Play(_ sender: Any) {
        isPlaying = !isPlaying
        if isPlaying == true {
            playSound()
        } else {
            playerAudioC.pause()
        }
        reloadAudio()
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: arrAudio[checkAudio], withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            playerAudioC = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let playerAudioC = playerAudioC else { return }

            print(url)

            playerAudioC.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func reloadAudio() {
        if isPlaying == true {
            btnPlay.setImage(UIImage(named: "PauseAudio"), for: .normal)
        } else {
            btnPlay.setImage(UIImage(named: "PlayAudio"), for: .normal)
        }
    }
    
}
