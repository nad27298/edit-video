//
//  OptiVideoEditor.swift
//  VideoEditor
//
//  Created by Optisol on 21/07/19.
//  Copyright © 2019 optisol. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AVKit
import Photos

let tempVideoName = "TempVideoName"
let tempVideoName2 = "TempVideoName2"

class EditVideoManager: NSObject {
    
    func verifyPresetForAsset(preset: String, asset: AVAsset) -> Bool {
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        let filteredPresets = compatiblePresets.filter { $0 == preset }
        
        return filteredPresets.count > 0 || preset == AVAssetExportPresetHighestQuality
    }
    
    func authorize(_ status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(), fromViewController: UIViewController, completion: @escaping (_ authorized: Bool) -> Void) {
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.authorize(status, fromViewController: fromViewController, completion: completion)
                })
            })
        default: ()
            DispatchQueue.main.async(execute: { () -> Void in
                completion(false)
            })
        }
    }
    
    //MARK: -- Addfilte
    func getTempVideoUrl() -> String {
        let fileManager = FileManager.default
        if NSSearchPathForDirectoriesInDomains(.documentationDirectory, .userDomainMask, true).count > 0 {
            let path = (NSSearchPathForDirectoriesInDomains(.documentationDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("Temporary")
            print("url: \(path)")
            if !fileManager.fileExists(atPath: path) {
                try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            }
            return path
        }
        return ""
    }
    
    
    //MARK: Add filter to video
    func addfiltertoVideo(strfiltername : String, strUrl : URL, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        
        //Filter Name
        let filter = CIFilter(name:strfiltername)
        
        //Asset
        let asset = AVAsset(url: strUrl)
        
        //Create Directory path for Save
        let documentDirectory = URL.init(fileURLWithPath: self.getTempVideoUrl())
        
        var outputURL = documentDirectory.appendingPathComponent("EffectVideo")
        do {
            try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(outputURL.lastPathComponent).mp4")
        }catch let error {
            failure(error.localizedDescription)
        }
        
        //Remove existing file
        self.deleteFile(outputURL)
        
        //AVVideoComposition
        let composition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
            
            // Clamp to avoid blurring transparent pixels at the image edges
            let source = request.sourceImage.clampedToExtent()
            filter?.setValue(source, forKey: kCIInputImageKey)
            
            // Crop the blurred output to the bounds of the original image
            let output = filter?.outputImage!.cropped(to: request.sourceImage.extent)
            
            // Provide the filter output to the composition
            request.finish(with: output!, context: nil)
            
        })
        
        //export the video to as per your requirement conversion
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputFileType = AVFileType.mov
        exportSession.outputURL = outputURL
        exportSession.videoComposition = composition
        
        exportSession.exportAsynchronously(completionHandler: {
            switch exportSession.status {
            case .completed:
                success(outputURL)
            case .failed:
                failure(exportSession.error?.localizedDescription)
                
            case .cancelled:
                failure(exportSession.error?.localizedDescription)
                
            default:
                failure(exportSession.error?.localizedDescription)
            }
        })
    }
    
    //MARK : add filter to video placeholder image
    func convertImageToBW(filterName : String ,image:UIImage) -> UIImage {
        
        let filter = CIFilter(name: filterName)
        
        // convert UIImage to CIImage and set as input
        let ciInput = CIImage(image: image)
        filter?.setValue(ciInput, forKey: "inputImage")
        
        // get output CIImage, render as CGImage first to retain proper UIImage scale
        let ciOutput = filter?.outputImage
        let ciContext = CIContext()
        let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!)
        
        return UIImage(cgImage: cgImage!)
    }
    
    //MARK: Thumbnail Image generate
    func generateThumbnail(path: URL) -> UIImage? {
        // getting image from video
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print(error)
            return nil
        }
    }
    
    //MARK: -- trim audio
    func trimAudio(sourceURL: URL, startTime: Double, stopTime: Double, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        /// Asset
        let asset = AVURLAsset.init(url: sourceURL)
        
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith:asset)
        
        if compatiblePresets.contains(AVAssetExportPresetMediumQuality) {
            
            //Create Directory path for Save
            if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count > 0{
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                var outputURL = documentDirectory.appendingPathComponent("\("TrimAudio")\(randomString(length:10))")
                do {
                    try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                    outputURL = outputURL.appendingPathComponent("\(sourceURL.lastPathComponent).m4a")
                }catch let error {
                    failure(error.localizedDescription)
                }
                
                //Remove existing file
                self.deleteFile(outputURL)
                
                //export the audio to as per your requirement conversion
                guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else{return}
                exportSession.outputURL = outputURL
                exportSession.outputFileType = AVFileType.m4a
                
                let start: CMTime = CMTimeMakeWithSeconds(startTime, preferredTimescale: asset.duration.timescale)
                let stop: CMTime = CMTimeMakeWithSeconds(stopTime, preferredTimescale: asset.duration.timescale)
                let range: CMTimeRange = CMTimeRangeFromTimeToTime(start: start, end: stop)
                exportSession.timeRange = range
                
                exportSession.exportAsynchronously(completionHandler: {
                    switch exportSession.status {
                    case .completed:
                        success(outputURL)
                        
                    case .failed:
                        if let _error = exportSession.error?.localizedDescription {
                            failure(_error)
                        }
                        
                    case .cancelled:
                        if let _error = exportSession.error?.localizedDescription {
                            failure(_error)
                        }
                        
                    default:
                        if let _error = exportSession.error?.localizedDescription {
                            failure(_error)
                        }
                    }
                })
            }
        }
    }
    
    
    //MARK: Mergh Audio to Video
    func mergeVideoWithAudio(videoUrl: URL, audioUrl: URL, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        
        
        let mixComposition: AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack: [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack: [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        
        let aVideoAsset: AVAsset = AVAsset(url: videoUrl)
        let aAudioAsset: AVAsset = AVAsset(url: audioUrl)
        
        
        if let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid), let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
            mutableCompositionVideoTrack.append(videoTrack)
            mutableCompositionAudioTrack.append(audioTrack)
            
            if let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: .video).first, let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: .audio).first {
                do {
                    try mutableCompositionVideoTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)
                    try mutableCompositionAudioTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: CMTime.zero)
                    videoTrack.preferredTransform = aVideoAssetTrack.preferredTransform
                    
                } catch{
                    print(error)
                }
                
                
                totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero,duration: aVideoAssetTrack.timeRange.duration)
            }
        }
        
        let mutableVideoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mutableVideoComposition.renderSize = CGSize(width: 480, height: 640)
        
        if let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let outputURL = URL(fileURLWithPath: documentsPath).appendingPathComponent("\("Audio").m4v")
            
            do {
                if FileManager.default.fileExists(atPath: outputURL.path) {
                    
                    try FileManager.default.removeItem(at: outputURL)
                }
            } catch { }
            
            if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
                exportSession.outputURL = outputURL
                exportSession.outputFileType = AVFileType.mp4
                exportSession.shouldOptimizeForNetworkUse = true
                
                /// try to export the file and handle the status cases
                exportSession.exportAsynchronously(completionHandler: {
                    switch exportSession.status {
                    case .failed:
                        if let _error = exportSession.error {
                            failure(_error.localizedDescription)
                        }
                        
                    case .cancelled:
                        if let _error = exportSession.error {
                            failure(_error.localizedDescription)
                        }
                        
                    default:
                        print("finished")
                        success(outputURL)
                    }
                })
            } else {
                failure(nil)
            }
        }
    }
    
    //MARK: crop the Audio which you select portion
    func trimVideo(sourceURL: URL, startTime: Double, endTime: Double, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        
        let asset = AVAsset(url: sourceURL)
        if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count > 0{
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let outputURL = documentDirectory.appendingPathComponent("\("TrimVideo")\(randomString(length:10)).mp4")
            //Remove existing file
            self.deleteFile(outputURL)
            
            //export the video to as per your requirement conversion
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            
            let timeRange = CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: 1000),
                                        end: CMTime(seconds: endTime, preferredTimescale: 1000))
            
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously(completionHandler: {
                switch exportSession.status {
                case .completed:
                    success(outputURL)
                    
                case .failed:
                    failure(exportSession.error?.localizedDescription)
                    
                case .cancelled:
                    failure(exportSession.error?.localizedDescription)
                    
                default:
                    failure(exportSession.error?.localizedDescription)
                }
            })
        }
    }
    
    
    //MARK: -- Cut video
    
    /*
     func cutVideo(sourceURL: URL, points: [(Double, Double)], success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
     let asset = AVAsset.init(url: sourceURL)
     let secondAsset = AVAsset.init(url: sourceURL)
     
     var trimPoints: [(CMTime, CMTime)] = []
     for (startTime, endTime) in points {
     let time = (CMTime(seconds: startTime, preferredTimescale: asset.duration.timescale),CMTime(seconds: endTime, preferredTimescale: asset.duration.timescale))
     trimPoints.append(time)
     }
     
     let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
     let outputURL = documentDirectory.appendingPathComponent("\(tempVideoName2).mp4")
     
     //Remove existing file
     self.deleteFile(outputURL)
     
     let options = [ AVURLAssetPreferPreciseDurationAndTimingKey: true ]
     
     var isAudio = false
     if let _ = asset.tracks(withMediaType: AVMediaType.audio).first{
     isAudio = true
     }
     let preferredPreset = AVAssetExportPresetHighestQuality
     
     //Mix
     let mixComposition = AVMutableComposition()
     guard
     let firstTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
     preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
     else {
     return
     }
     do {
     try firstTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: trimPoints[0].0),
     of: asset.tracks(withMediaType: AVMediaType.video)[0],
     at: CMTime.zero)
     } catch {
     print("Failed to load first track")
     return
     }
     
     guard
     let secondTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
     preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
     else {
     return
     }
     do {
     try firstTrack.insertTimeRange(CMTimeRange(start: trimPoints[0].1, end: asset.duration),
     of: asset.tracks(withMediaType: AVMediaType.video)[0],
     at: trimPoints[0].0)
     } catch {
     print("Failed to load second track")
     return
     }
     
     
     guard let exportSession = AVAssetExportSession(asset: mixComposition,
     presetName: AVAssetExportPresetHighestQuality) else {
     return
     }
     exportSession.outputURL = outputURL
     exportSession.outputFileType = AVFileType.mp4
     exportSession.shouldOptimizeForNetworkUse = true
     //        exportSession.videoComposition = mainComposition
     exportSession.exportAsynchronously(completionHandler: {
     switch exportSession.status {
     case .completed:
     success(outputURL)
     case .failed:
     if let _error = exportSession.error?.localizedDescription {
     failure(_error)
     }
     
     case .cancelled:
     if let _error = exportSession.error?.localizedDescription {
     failure(_error)
     }
     
     default:
     if let _error = exportSession.error?.localizedDescription {
     failure(_error)
     }
     }
     })
     
     }*/
    
    //MARK: -- rorate
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func rotateVideo(sourceUrl: URL, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        let asset : AVURLAsset = AVURLAsset(url: sourceUrl, options: nil)
        
        if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count > 0{
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let outputURL = documentDirectory.appendingPathComponent("\("Rotare")\(randomString(length:10)).mp4")
            
            //Remove existing file
            //self.deleteFile(outputURL)
            
            let fileManager = FileManager.default
            
            
            if asset.tracks(withMediaType: AVMediaType.video).count > 0{
                let clipVideoTrack: AVAssetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
                
                let videoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
                
                videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
                
                videoComposition.renderSize = CGSize.init(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.width)
                
                let instruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
                instruction.timeRange = CMTimeRangeMake(start: CMTime.zero,  duration: CMTimeMakeWithSeconds(60, preferredTimescale: 30))
                
                let transformer: AVMutableVideoCompositionLayerInstruction =
                    AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
                
                let t1: CGAffineTransform = CGAffineTransform(translationX: clipVideoTrack.naturalSize.height, y: 0)
                
                let t2: CGAffineTransform = t1.rotated(by: CGFloat(Double.pi/2))
                
                let finalTransform: CGAffineTransform = t2
                
                
                transformer.setTransform(finalTransform, at: CMTime.zero)
                instruction.layerInstructions = [transformer]
                
                videoComposition.instructions = [instruction]
                
                let exportUrl = outputURL
                
                if(fileManager.fileExists(atPath: exportUrl.path as String)) {
                    
                    try! fileManager.removeItem(at: exportUrl)
                }
                
                let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
                exporter!.videoComposition = videoComposition
                exporter!.outputFileType = AVFileType.mov
                exporter!.outputURL = exportUrl
                exporter!.exportAsynchronously(completionHandler: { () -> Void in
                    
                    print(CMTimeGetSeconds((exporter?.asset.duration)!))
                    
                    switch exporter!.status {
                    case .completed :
                        success(exportUrl)
                    default:
                        print(exporter?.error ?? "")
                        failure(exporter?.error?.localizedDescription ?? "")
                    }
                })
            }
        }
    }
    
    //MARK: -- speed
    
    func videoScaleAssetSpeed(fromURL url: URL,  by scale: Float64, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        
        /// Asset
        let asset = AVPlayerItem(url: url).asset
        
        // Composition Audio Video
        let mixComposition = AVMutableComposition()
        
        //TotalTimeRange
        let timeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)
        
        /// Video Tracks
        let videoTracks = asset.tracks(withMediaType: AVMediaType.video)
        if videoTracks.count == 0 {
            /// Can not find any video track
            return
        }
        
        /// Video track
        let videoTrack = videoTracks.first!
        
        let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        /// Audio Tracks
        let audioTracks = asset.tracks(withMediaType: AVMediaType.audio)
        if audioTracks.count > 0 {
            /// Use audio if video contains the audio track
            let compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            /// Audio track
            let audioTrack = audioTracks.first!
            do {
                try compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: CMTime.zero)
                let destinationTimeRange = CMTimeMultiplyByFloat64(asset.duration, multiplier:(1/scale))
                compositionAudioTrack?.scaleTimeRange(timeRange, toDuration: destinationTimeRange)
                
                compositionAudioTrack?.preferredTransform = audioTrack.preferredTransform
                
            } catch _ {
                /// Ignore audio error
            }
        }
        
        do {
            try compositionVideoTrack?.insertTimeRange(timeRange, of: videoTrack, at: CMTime.zero)
            let destinationTimeRange = CMTimeMultiplyByFloat64(asset.duration, multiplier:(1/scale))
            compositionVideoTrack?.scaleTimeRange(timeRange, toDuration: destinationTimeRange)
            
            /// Keep original transformation
            compositionVideoTrack?.preferredTransform = videoTrack.preferredTransform
            
            if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count > 0{
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let outputURL = documentDirectory.appendingPathComponent("\("Speed")\(randomString(length:10)).mp4")
                //Remove existing file
                self.deleteFile(outputURL)
                
                //export the video to as per your requirement conversion
                if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
                    exportSession.outputURL = outputURL
                    exportSession.outputFileType = AVFileType.mp4
                    exportSession.shouldOptimizeForNetworkUse = true
                    
                    /// try to export the file and handle the status cases
                    exportSession.exportAsynchronously(completionHandler: {
                        switch exportSession.status {
                        case .completed :
                            success(outputURL)
                        case .failed:
                            if let _error = exportSession.error?.localizedDescription {
                                failure(_error)
                            }
                        case .cancelled:
                            if let _error = exportSession.error?.localizedDescription {
                                failure(_error)
                            }
                        default:
                            if let _error = exportSession.error?.localizedDescription {
                                failure(_error)
                            }
                        }
                    })
                } else {
                    failure(nil)
                }
            }
        } catch {
            // Handle the error
            failure("Inserting time range failed.")
        }
        
    }
    
    //MARK: -- Crop
    
    func cropVideo(sourceUrl: URL, width: Int, height: Int, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count > 0{
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let outputURL = documentDirectory.appendingPathComponent("\("Crop")\(randomString(length:10)).mp4")
            
            //Remove existing file
            self.deleteFile(outputURL)
            
            let asset : AVAsset = AVAsset(url: sourceUrl)
            if asset.tracks(withMediaType: AVMediaType.video).count > 0{
                let videoSizeone = asset.tracks(withMediaType: AVMediaType.video)[0].naturalSize
                let videoWidth = videoSizeone.width
                let videoHeight = videoSizeone.height
                
                print(videoWidth, videoHeight)
                
                let timeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)
                if asset.tracks(withMediaType: AVMediaType.video).count > 0{
                    let videoCompositionTrack: AVAssetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
                    
                    let layerInstructions = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
                    _ = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
                    
                    var renderSize = CGSize()
                    var delta: CGFloat = 0.0
                    
                    if width == 0 {
                        renderSize = CGSize(width: videoWidth, height: videoHeight)
                    } else if width == 1 {
                        renderSize = CGSize(width: videoHeight, height: videoHeight)
                        delta = (videoWidth - videoHeight) / 2
                    } else if width > height {
                        renderSize = CGSize(width: Int(videoWidth), height: Int(videoWidth) / width * height)
                        delta = (videoHeight - renderSize.height) / 2
                    } else if width < height {
                        renderSize = CGSize(width: Int(videoHeight) / height * width, height: Int(videoHeight))
                        delta = (videoWidth - renderSize.width) / 2
                    }
                    print("--------rendersize:  ", renderSize)
                    if width > height {
                        layerInstructions.setTransform(CGAffineTransform(translationX: 0, y: -(delta)), at: CMTime.zero)
                    } else {
                        layerInstructions.setTransform(CGAffineTransform(translationX: -(delta), y: 0), at: CMTime.zero)
                    }
                    layerInstructions.setOpacity(1.0, at: CMTime.zero)
                    let mainInstructions = AVMutableVideoCompositionInstruction()
                    mainInstructions.timeRange = timeRange
                    mainInstructions.layerInstructions = [layerInstructions]
                    let videoComposition = AVMutableVideoComposition()
                    videoComposition.renderSize = renderSize
                    videoComposition.instructions = [mainInstructions]
                    videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
                    
                    let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
                    exportSession!.outputFileType = AVFileType.mp4
                    //        exportSession!.shouldOptimizeForNetworkUse = true
                    exportSession!.videoComposition = videoComposition
                    exportSession!.outputURL = outputURL
                    exportSession!.exportAsynchronously(completionHandler: {
                        
                        switch exportSession!.status {
                        case .completed :
                            success(outputURL)
                        default:
                            print(exportSession?.error ?? "")
                            failure(exportSession?.error?.localizedDescription ?? "")
                        }
                    })
                }
            }
            
        }
    }
    
    
    //MARK: -- background, frame
    func addBackgroundToVideo(videoUrl: URL, image: UIImage?, margin: CGFloat, radious: CGFloat = 0, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        let asset = AVURLAsset(url: videoUrl )
        let composition = AVMutableComposition.init()
        composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        if asset.tracks(withMediaType: AVMediaType.video).count > 0{
            
            let clipVideoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
            
            
            // Rotate to potrait
            let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
            
            
            let videoTransform:CGAffineTransform = clipVideoTrack.preferredTransform
            
            
            
            //fix orientation
            var videoAssetOrientation_  = UIImage.Orientation.up
            
            var isVideoAssetPortrait_  = false
            
            if videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0 {
                videoAssetOrientation_ = UIImage.Orientation.right
                isVideoAssetPortrait_ = true
            }
            if videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0 {
                videoAssetOrientation_ =  UIImage.Orientation.left
                isVideoAssetPortrait_ = true
            }
            if videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0 {
                videoAssetOrientation_ =  UIImage.Orientation.up
            }
            if videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0 {
                videoAssetOrientation_ = UIImage.Orientation.down;
            }
            
            
            transformer.setTransform(clipVideoTrack.preferredTransform, at: CMTime.zero)
            transformer.setOpacity(0.0, at: asset.duration)
            
            //adjust the render size if neccessary
            var naturalSize: CGSize
            if(isVideoAssetPortrait_){
                naturalSize = CGSize(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.width)
            } else {
                naturalSize = clipVideoTrack.naturalSize;
            }
            
            var renderWidth: CGFloat!
            var renderHeight: CGFloat!
            
            renderWidth = naturalSize.width
            renderHeight = naturalSize.height
            
            let parentlayer = CALayer()
            let videoLayer = CALayer()
            let watermarkLayer = CALayer()
            let background = UIImageView()
            
            //        let videoComposition = AVMutableVideoComposition()
            //        videoComposition.renderSize = CGSize(width: renderWidth, height: renderHeight)
            //        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
            //        videoComposition.renderScale = 1.0
            //
            //        parentlayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
            //        videoLayer.frame = CGRect(x: margin, y: margin, width: renderWidth - margin*2, height: renderHeight - margin*2)
            //        watermarkLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
            //
            //        background.image = image
            //        background.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
            //        background.contentMode = .scaleAspectFill
            //        background.clipsToBounds = true
            ////        background.backgroundColor = bgColor
            //        background.layer.cornerRadius = radious
            //
            //        //        parentlayer.backgroundColor = bgColor?.cgColor
            //
            //
            //        //        if let image = image {
            //        //            parentlayer.contents = image.cgImage
            //        //        }
            //
            //        parentlayer.cornerRadius = radious
            //
            //        parentlayer.addSublayer(background.layer)
            //        parentlayer.addSublayer(videoLayer)
            //        //                   parentlayer.addSublayer(watermarkLayer)
            //
            //
            //
            //        // Add watermark to video
            //        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayers: [videoLayer], in: parentlayer)
            //
            //        let instruction = AVMutableVideoCompositionInstruction()
            //        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeMakeWithSeconds(asset.duration.seconds + 2, preferredTimescale: 30))
            //
            //
            //        instruction.layerInstructions = [transformer]
            //        videoComposition.instructions = [instruction]
            
            
            let filter = CIFilter(name: "CIGaussianBlur")
            let compositionPRO = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
                // Clamp to avoid blurring transparent pixels at the image edges
                let source: CIImage? = request.sourceImage.clampedToExtent()
                filter?.setValue(source, forKey: kCIInputImageKey)
                
                filter?.setValue(10.0, forKey: kCIInputRadiusKey)
                
                // Crop the blurred output to the bounds of the original image
                let output: CIImage? = filter?.outputImage?.cropped(to: request.sourceImage.extent)
                
                // Provide the filter output to the composition
                if let anOutput = output {
                    request.finish(with: anOutput, context: nil)
                }
                
            })
            
            
            // Create a destination URL.
            if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count > 0{
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let outputURL = documentDirectory.appendingPathComponent("\("BG")\(randomString(length:10)).mp4")
                
                //Remove existing file
                self.deleteFile(outputURL)
                print(outputURL)
                guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
                exportSession.outputFileType =  .mp4
                exportSession.outputURL = outputURL
                exportSession.videoComposition = compositionPRO
                
                
                exportSession.exportAsynchronously(completionHandler: {
                    switch exportSession.status {
                    case .completed:
                        success(outputURL)
                        
                    case .failed:
                        failure(exportSession.error?.localizedDescription)
                        
                    case .cancelled:
                        failure(exportSession.error?.localizedDescription)
                        
                    default:
                        failure(exportSession.error?.localizedDescription)
                    }
                })
            }
        }
    }
    
    //MARK: -- Color, frame
    func addColorToVideo(videoUrl: URL, bgColor: UIColor?, margin: CGFloat, radious: CGFloat = 0, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        let asset = AVURLAsset(url: videoUrl )
        let composition = AVMutableComposition.init()
        composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        if asset.tracks(withMediaType: AVMediaType.video).count > 0{
            
            let clipVideoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
            
            
            // Rotate to potrait
            let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
            
            
            let videoTransform:CGAffineTransform = clipVideoTrack.preferredTransform
            
            
            
            //fix orientation
            var videoAssetOrientation_  = UIImage.Orientation.up
            
            var isVideoAssetPortrait_  = false
            
            if videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0 {
                videoAssetOrientation_ = UIImage.Orientation.right
                isVideoAssetPortrait_ = true
            }
            if videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0 {
                videoAssetOrientation_ =  UIImage.Orientation.left
                isVideoAssetPortrait_ = true
            }
            if videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0 {
                videoAssetOrientation_ =  UIImage.Orientation.up
            }
            if videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0 {
                videoAssetOrientation_ = UIImage.Orientation.down;
            }
            
            
            transformer.setTransform(clipVideoTrack.preferredTransform, at: CMTime.zero)
            transformer.setOpacity(0.0, at: asset.duration)
            
            //adjust the render size if neccessary
            var naturalSize: CGSize
            if(isVideoAssetPortrait_){
                naturalSize = CGSize(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.width)
            } else {
                naturalSize = clipVideoTrack.naturalSize;
            }
            
            var renderWidth: CGFloat!
            var renderHeight: CGFloat!
            
            renderWidth = naturalSize.width
            renderHeight = naturalSize.height
            
            let parentlayer = CALayer()
            let videoLayer = CALayer()
            let watermarkLayer = CALayer()
            let background = UIImageView()
            
            let videoComposition = AVMutableVideoComposition()
            videoComposition.renderSize = CGSize(width: renderWidth, height: renderHeight)
            videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
            videoComposition.renderScale = 1.0
            
            parentlayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
            videoLayer.frame = CGRect(x: margin, y: margin, width: renderWidth - margin*2, height: renderHeight - margin*2)
            watermarkLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
            
            background.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
            background.contentMode = .scaleAspectFill
            background.clipsToBounds = true
            background.backgroundColor = bgColor
            background.layer.cornerRadius = radious
            parentlayer.cornerRadius = radious
            parentlayer.addSublayer(background.layer)
            parentlayer.addSublayer(videoLayer)
            
            
            
            // Add watermark to video
            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayers: [videoLayer], in: parentlayer)
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeMakeWithSeconds(asset.duration.seconds + 2, preferredTimescale: 30))
            
            
            instruction.layerInstructions = [transformer]
            videoComposition.instructions = [instruction]
            
            
            
            // Create a destination URL.
            if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count > 0{
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let outputURL = documentDirectory.appendingPathComponent("\("Color")\(randomString(length:10)).mp4")
                
                //Remove existing file
                self.deleteFile(outputURL)
                
                guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
                exportSession.outputFileType = AVFileType.mov
                exportSession.outputURL = outputURL
                exportSession.videoComposition = videoComposition
                
                
                exportSession.exportAsynchronously(completionHandler: {
                    switch exportSession.status {
                    case .completed:
                        success(outputURL)
                        
                    case .failed:
                        failure(exportSession.error?.localizedDescription)
                        
                    case .cancelled:
                        failure(exportSession.error?.localizedDescription)
                        
                    default:
                        failure(exportSession.error?.localizedDescription)
                    }
                })
            }
        }
    }
    
    //MARK: -- Flip
    
    func flipVideo(videoUrl: URL, x: Int, y: Int, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        let asset = AVURLAsset(url: videoUrl )
        let composition = AVMutableComposition.init()
        composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        if asset.tracks(withMediaType: AVMediaType.video).count > 0{
            
            let clipVideoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
            
            
            // Rotate to potrait
            let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
            
            
            let videoTransform:CGAffineTransform = clipVideoTrack.preferredTransform
            
            
            
            //fix orientation
            var videoAssetOrientation_  = UIImage.Orientation.up
            
            var isVideoAssetPortrait_  = false
            
            if videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0 {
                videoAssetOrientation_ = UIImage.Orientation.right
                isVideoAssetPortrait_ = true
            }
            if videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0 {
                videoAssetOrientation_ =  UIImage.Orientation.left
                isVideoAssetPortrait_ = true
            }
            if videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0 {
                videoAssetOrientation_ =  UIImage.Orientation.up
            }
            if videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0 {
                videoAssetOrientation_ = UIImage.Orientation.down;
            }
            
            
            transformer.setTransform(clipVideoTrack.preferredTransform, at: CMTime.zero)
            transformer.setOpacity(0.0, at: asset.duration)
            
            
            
            
            
            //adjust the render size if neccessary
            var naturalSize: CGSize
            if(isVideoAssetPortrait_){
                naturalSize = CGSize(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.width)
            } else {
                naturalSize = clipVideoTrack.naturalSize;
            }
            
            
            
            
            var renderWidth: CGFloat!
            var renderHeight: CGFloat!
            
            renderWidth = naturalSize.width
            renderHeight = naturalSize.height
            
            let parentlayer = CALayer()
            let videoLayer = CALayer()
            let watermarkLayer = CALayer()
            
            
            let videoComposition = AVMutableVideoComposition()
            videoComposition.renderSize = CGSize(width: renderWidth, height: renderHeight)
            videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
            videoComposition.renderScale = 1.0
            
            parentlayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
            videoLayer.frame = CGRect(x: 0, y: 0, width: renderWidth, height: renderHeight)
            videoLayer.transform = CATransform3DScale(CATransform3DMakeRotation(0, 0, 0, 1),
                                                      CGFloat(x), CGFloat(y), 1)
            watermarkLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
            
            parentlayer.addSublayer(videoLayer)
            
            // Add watermark to video
            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayers: [videoLayer], in: parentlayer)
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeMakeWithSeconds(120, preferredTimescale: 30))
            
            
            instruction.layerInstructions = [transformer]
            videoComposition.instructions = [instruction]
            
            
            
            // Create a destination URL.
            if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count > 0{
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let outputURL = documentDirectory.appendingPathComponent("\("Flip")\(randomString(length:10)).mp4")
                
                //Remove existing file
                self.deleteFile(outputURL)
                
                guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
                exportSession.outputFileType = AVFileType.mov
                exportSession.outputURL = outputURL
                exportSession.videoComposition = videoComposition
                
                
                exportSession.exportAsynchronously(completionHandler: {
                    switch exportSession.status {
                    case .completed:
                        success(outputURL)
                        
                    case .failed:
                        failure(exportSession.error?.localizedDescription)
                        
                    case .cancelled:
                        failure(exportSession.error?.localizedDescription)
                        
                    default:
                        failure(exportSession.error?.localizedDescription)
                    }
                })
            }
        }
    }
    
    //MARK: -- merge video
    
    func mergeMovies(videoAssets: [AVAsset], success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        let mainComposition = AVMutableComposition()
        let compositionVideoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        compositionVideoTrack?.preferredTransform = CGAffineTransform(rotationAngle: .pi / 3)
        
        let soundtrackTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        var insertTime = CMTime.zero
        
        for videoAsset in videoAssets {
            if videoAsset.tracks(withMediaType: .audio).count > 0 && videoAsset.tracks(withMediaType: .video).count > 0{
                try! compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .video)[0], at: insertTime)
                try! soundtrackTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .audio)[0], at: insertTime)
                insertTime = CMTimeAdd(insertTime, videoAsset.duration)
            }
            
        }
        
        //Create Directory path for Save
        if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count > 0{
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            var outputURL = documentDirectory.appendingPathComponent("\("MergeTwoVideos")\(randomString(length:10))")
            do {
                try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                outputURL = outputURL.appendingPathComponent("\(outputURL.lastPathComponent).m4v")
            }catch let error {
                failure(error.localizedDescription)
            }
            
            //Remove existing file
            self.deleteFile(outputURL)
            
            //export the video to as per your requirement conversion
            if let exportSession = AVAssetExportSession(asset: mainComposition, presetName: AVAssetExportPresetHighestQuality) {
                exportSession.outputURL = outputURL
                exportSession.outputFileType = AVFileType.mp4
                exportSession.shouldOptimizeForNetworkUse = true
                
                /// try to export the file and handle the status cases
                exportSession.exportAsynchronously(completionHandler: {
                    switch exportSession.status {
                    case .completed :
                        success(outputURL)
                    case .failed:
                        if let _error = exportSession.error?.localizedDescription {
                            failure(_error)
                        }
                    case .cancelled:
                        if let _error = exportSession.error?.localizedDescription {
                            failure(_error)
                        }
                    default:
                        if let _error = exportSession.error?.localizedDescription {
                            failure(_error)
                        }
                    }
                })
            } else {
                failure("video export session failed")
            }
        }
    }
    
    //MARK: -- Add sticker
    
    func addStickertoVideo(videoUrl: URL, imageName name : String, position : Int,  success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        
        /// Asset
        let asset = AVPlayerItem(url: videoUrl).asset
        
        // Create an AVMutableComposition for editing
        let mutableComposition = getVideoComposition(asset: asset)
        if asset.tracks(withMediaType: AVMediaType.video).count > 0{
            let videoSizeone = asset.tracks(withMediaType: AVMediaType.video)[0].naturalSize
            let videoWidth = videoSizeone.width
            let videoHeight = videoSizeone.height
            
            // Create a CALayer instance and configurate it
            let parentLayer = CALayer()
            if name != "" {
                let stickerLayer = CALayer()
                stickerLayer.contents = UIImage(named: name)?.cgImage
                stickerLayer.contentsGravity = CALayerContentsGravity.resizeAspect
                let stickerWidth = videoWidth / 6
                let stickerX = videoWidth * CGFloat(5 * (position % 3)) / 12
                let stickerY = videoHeight * CGFloat(position / 3) / 3
                stickerLayer.frame = CGRect(x: stickerX, y: stickerY, width: stickerWidth, height: stickerWidth)
                stickerLayer.opacity = 0.9
                parentLayer.addSublayer(stickerLayer)
            }
            
            let videoTrack: AVAssetTrack = mutableComposition.tracks(withMediaType: AVMediaType.video)[0]
            let videoSizetwo = videoTrack.naturalSize
            
            let videoLayer = CALayer()
            videoLayer.frame = CGRect(x: 0, y: 0, width: videoSizetwo.width, height: videoSizetwo.height)
            
            let containerLayer = CALayer()
            containerLayer.frame = CGRect(x: 0, y: 0, width: videoSizetwo.width, height: videoSizetwo.height)
            containerLayer.addSublayer(videoLayer)
            containerLayer.addSublayer(parentLayer)
            
            let layerComposition = AVMutableVideoComposition()
            layerComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
            layerComposition.renderSize = videoSizetwo
            layerComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: containerLayer)
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: mutableComposition.duration)
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            instruction.layerInstructions = [layerInstruction]
            layerComposition.instructions = [instruction]
            
            //Create Directory path for Save
            if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count > 0{
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                var outputURL = documentDirectory.appendingPathComponent("\("StickerVideo")\(randomString(length:10))")
                do {
                    try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                    outputURL = outputURL.appendingPathComponent("\(outputURL.lastPathComponent).m4v")
                }catch let error {
                    print(error)
                }
                
                //Remove existing file
                self.deleteFile(outputURL)
                
                //export the video to as per your requirement conversion
                if let exportSession = AVAssetExportSession(asset: mutableComposition, presetName: AVAssetExportPresetHighestQuality) {
                    exportSession.outputURL = outputURL
                    exportSession.outputFileType = AVFileType.mov
                    exportSession.shouldOptimizeForNetworkUse = true
                    exportSession.videoComposition = layerComposition
                    /// try to export the file and handle the status cases
                    exportSession.exportAsynchronously(completionHandler: {
                        switch exportSession.status {
                        case .completed :
                            success(outputURL)
                        case .failed:
                            if let _error = exportSession.error?.localizedDescription {
                                failure(_error)
                            }
                        case .cancelled:
                            if let _error = exportSession.error?.localizedDescription {
                                failure(_error)
                            }
                        default:
                            if let _error = exportSession.error?.localizedDescription {
                                failure(_error)
                            }
                        }
                    })
                } else {
                    failure("video export session failed")
                }
            }
        }
    }
    
    
    //MARK: -- Add Image
    func addImagetoVideo(videoUrl: URL, imageName name : UIImage, position : Int,  success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        
        /// Asset
        let asset = AVPlayerItem(url: videoUrl).asset
        
        // Create an AVMutableComposition for editing
        let mutableComposition = getVideoComposition(asset: asset)
        if asset.tracks(withMediaType: AVMediaType.video).count > 0{
            let videoSizeone = asset.tracks(withMediaType: AVMediaType.video)[0].naturalSize
            let videoWidth = videoSizeone.width
            let videoHeight = videoSizeone.height
            
            // Create a CALayer instance and configurate it
            let parentLayer = CALayer()
            
            let stickerLayer = CALayer()
            print(name.size)
            stickerLayer.contents = name
            stickerLayer.contentsGravity = CALayerContentsGravity.resizeAspect
            let stickerWidth = videoWidth / 6
            let stickerX = videoWidth * CGFloat(5 * (position % 3)) / 12
            let stickerY = videoHeight * CGFloat(position / 3) / 3
            stickerLayer.frame = CGRect(x: stickerX, y: stickerY, width: stickerWidth, height: stickerWidth)
            stickerLayer.opacity = 0.9
            print(stickerLayer.preferredFrameSize())
            parentLayer.addSublayer(stickerLayer)
            
            let videoTrack: AVAssetTrack = mutableComposition.tracks(withMediaType: AVMediaType.video)[0]
            let videoSizetwo = videoTrack.naturalSize
            
            let videoLayer = CALayer()
            videoLayer.frame = CGRect(x: 0, y: 0, width: videoSizetwo.width, height: videoSizetwo.height)
            
            let containerLayer = CALayer()
            containerLayer.frame = CGRect(x: 0, y: 0, width: videoSizetwo.width, height: videoSizetwo.height)
            containerLayer.addSublayer(videoLayer)
            containerLayer.addSublayer(parentLayer)
            
            let layerComposition = AVMutableVideoComposition()
            layerComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
            layerComposition.renderSize = videoSizetwo
            layerComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: containerLayer)
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: mutableComposition.duration)
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            instruction.layerInstructions = [layerInstruction]
            layerComposition.instructions = [instruction]
            
            //Create Directory path for Save
            if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count > 0{
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                var outputURL = documentDirectory.appendingPathComponent("\("ImageVideo")\(randomString(length:10))")
                do {
                    try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                    outputURL = outputURL.appendingPathComponent("\(outputURL.lastPathComponent).m4v")
                }catch let error {
                    print(error)
                }
                
                //Remove existing file
                self.deleteFile(outputURL)
                
                //export the video to as per your requirement conversion
                if let exportSession = AVAssetExportSession(asset: mutableComposition, presetName: AVAssetExportPresetHighestQuality) {
                    exportSession.outputURL = outputURL
                    exportSession.outputFileType = AVFileType.mov
                    exportSession.shouldOptimizeForNetworkUse = true
                    exportSession.videoComposition = layerComposition
                    /// try to export the file and handle the status cases
                    exportSession.exportAsynchronously(completionHandler: {
                        switch exportSession.status {
                        case .completed :
                            success(outputURL)
                        case .failed:
                            if let _error = exportSession.error?.localizedDescription {
                                failure(_error)
                            }
                        case .cancelled:
                            if let _error = exportSession.error?.localizedDescription {
                                failure(_error)
                            }
                        default:
                            if let _error = exportSession.error?.localizedDescription {
                                failure(_error)
                            }
                        }
                    })
                } else {
                    failure("video export session failed")
                }
            }
        }
    }
    
    
    //MARK: -- Add Text
    
    
    func addTexttoVideo(videoUrl: URL, watermarkText text : String, position : Int,  success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        
        /// Asset
        let asset = AVPlayerItem(url: videoUrl).asset
        
        // Create an AVMutableComposition for editing
        let mutableComposition = getVideoComposition(asset: asset)
        if asset.tracks(withMediaType: AVMediaType.video).count > 0{
            let videoSizeone = asset.tracks(withMediaType: AVMediaType.video)[0].naturalSize
            let videoWidth = videoSizeone.width
            let videoHeight = videoSizeone.height
            
            // Create a CALayer instance and configurate it
            let parentLayer = CALayer()
            if text != "" {
                let textLayer = CATextLayer()
                textLayer.string = text
                textLayer.font = UIFont(name: "Trebuchet MS", size: 40) ?? UIFont.systemFont(ofSize: 40)
                if position % 3 == 0 {
                    textLayer.alignmentMode = CATextLayerAlignmentMode.left
                } else if position % 3 == 1 {
                    textLayer.alignmentMode = CATextLayerAlignmentMode.center
                } else {
                    textLayer.alignmentMode = CATextLayerAlignmentMode.right
                }
                
                let textWidth = videoWidth / 5
                let textX = videoWidth * CGFloat(5 * (position % 3)) / 12
                let textY = videoHeight * CGFloat(position / 3) / 3
                textLayer.frame = CGRect(x: textX , y: textY + 20, width: textWidth, height: 50)
                textLayer.opacity = 0.6
                parentLayer.addSublayer(textLayer)
            }
            
            let videoTrack: AVAssetTrack = mutableComposition.tracks(withMediaType: AVMediaType.video)[0]
            let videoSizetwo = videoTrack.naturalSize
            
            let videoLayer = CALayer()
            videoLayer.frame = CGRect(x: 0, y: 0, width: videoSizetwo.width, height: videoSizetwo.height)
            
            let containerLayer = CALayer()
            containerLayer.frame = CGRect(x: 0, y: 0, width: videoSizetwo.width, height: videoSizetwo.height)
            containerLayer.addSublayer(videoLayer)
            containerLayer.addSublayer(parentLayer)
            
            let layerComposition = AVMutableVideoComposition()
            layerComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
            layerComposition.renderSize = videoSizetwo
            layerComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: containerLayer)
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: mutableComposition.duration)
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            instruction.layerInstructions = [layerInstruction]
            layerComposition.instructions = [instruction]
            
            //Create Directory path for Save
            if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count > 0{
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                var outputURL = documentDirectory.appendingPathComponent("\("TextPro")\(randomString(length:10))")
                do {
                    try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                    outputURL = outputURL.appendingPathComponent("\(outputURL.lastPathComponent).m4v")
                }catch {
                    print(error)
                    failure(error.localizedDescription)
                }
                
                //Remove existing file
                self.deleteFile(outputURL)
                
                //export the video to as per your requirement conversion
                if let exportSession = AVAssetExportSession(asset: mutableComposition, presetName: AVAssetExportPresetHighestQuality) {
                    exportSession.outputURL = outputURL
                    exportSession.outputFileType = AVFileType.mov
                    exportSession.shouldOptimizeForNetworkUse = true
                    exportSession.videoComposition = layerComposition
                    /// try to export the file and handle the status cases
                    exportSession.exportAsynchronously(completionHandler: {
                        switch exportSession.status {
                        case .completed :
                            success(outputURL)
                        case .failed:
                            if let _error = exportSession.error?.localizedDescription {
                                failure(_error)
                            }
                        case .cancelled:
                            if let _error = exportSession.error?.localizedDescription {
                                failure(_error)
                            }
                        default:
                            if let _error = exportSession.error?.localizedDescription {
                                failure(_error)
                            }
                        }
                    })
                } else {
                    failure("video export session failed")
                }
            }else{
                failure("FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count == 0")
            }
            
        }else{
            failure("asset.tracks(withMediaType: AVMediaType.video).count == 0")
        }
    }
    
    //MARK: -- Delete Audio Video
    
    func deleteAudioFromVideo(sourceURL: URL, startTime: Double, endTime: Double, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        let asset = AVAsset(url: sourceURL)
        let composition = AVMutableComposition()
        let compositionVideoTrack: AVMutableCompositionTrack? = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let sourceVideoTrack: AVAssetTrack? = asset.tracks(withMediaType: .video)[0]
        let x: CMTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)
        _ = try? compositionVideoTrack!.insertTimeRange(x, of: sourceVideoTrack!, at: CMTime.zero)
        
        if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count > 0{
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            var outputURL = documentDirectory.appendingPathComponent("\("MuteVideo")\(randomString(length:10))")
            do {
                try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                outputURL = outputURL.appendingPathComponent("\(outputURL.lastPathComponent).mp4")
            }catch let error {
                print(error)
            }
            
            guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else { return }
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            let timeRange = CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: asset.duration.timescale),end: CMTime(seconds: endTime, preferredTimescale: asset.duration.timescale))
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously(completionHandler: {
                switch exportSession.status {
                case .completed:
                    success(outputURL)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
                        
                    }) { saved, error in
                        if saved {
                            print("saved")
                        }
                    }
                    
                case .failed:
                    failure(exportSession.error?.localizedDescription)
                    
                case .cancelled:
                    failure(exportSession.error?.localizedDescription)
                    
                default:
                    failure(exportSession.error?.localizedDescription)
                }
            })
        }
    }
    
    //MARK: -- Transition
    
    
    func transitionAnimation(videoUrl: URL, animation:Bool, type: Int, playerSize: CGRect,success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        var insertTime = CMTime.zero
        var arrayLayerInstructions:[AVMutableVideoCompositionLayerInstruction] = []
        var outputSize = CGSize(width: 0, height: 0)
        
        let aVideoAsset = AVAsset(url: videoUrl)
        
        // Determine video output size
        if aVideoAsset.tracks(withMediaType: AVMediaType.video).count > 0{
            let videoTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
            let assetInfo = self.orientationFromTransform(videoTrack.preferredTransform)
            var videoSize = videoTrack.naturalSize
            if assetInfo.isPortrait == true {
                videoSize.width = videoTrack.naturalSize.height
                videoSize.height = videoTrack.naturalSize.width
            }
            
            if videoSize.height > outputSize.height {
                outputSize = videoSize
            }
            
            
            if outputSize.width == 0 || outputSize.height == 0 {
                outputSize = defaultSize
            }
            
            // Init composition
            let mixComposition = AVMutableComposition()
            
            // Get video track
            guard let videoTrackk = aVideoAsset.tracks(withMediaType: AVMediaType.video).first else {
                return
            }
            
            // Get audio track
            var audioTrack:AVAssetTrack?
            //  if videoAsset.tracks(withMediaType: AVMediaType.audio).count > 0 {
            audioTrack = aVideoAsset.tracks(withMediaType: AVMediaType.audio).first
            /* }
             else {
             audioTrack = silenceSoundTrack
             }*/
            
            // Init video & audio composition track
            let videoCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                                       preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            
            let audioCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                       preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            
            do {
                let startTime = CMTime.zero
                let duration = aVideoAsset.duration
                
                // Add video track to video composition at specific time
                try videoCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: startTime, duration: duration),
                                                           of: videoTrackk,
                                                           at: insertTime)
                
                // Add audio track to audio composition at specific time
                if let audioTrack = audioTrack {
                    try audioCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: startTime, duration: duration), of: audioTrack, at: insertTime)
                }
                
                // Add instruction for video track
                let layerInstruction = self.videoCompositionInstructionForTrackWithSizeandTime(track: videoCompositionTrack!, asset: aVideoAsset, standardSize: outputSize, atTime: insertTime)
                
                // Hide video track before changing to new track
                let endTime = CMTimeAdd(insertTime, duration)
                
                //if animation {
                let timeScale = aVideoAsset.duration.timescale
                let durationAnimation = CMTime.init(seconds: 1, preferredTimescale: timeScale)
                
                // layerInstruction.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity: 0.0, timeRange: CMTimeRange.init(start: endTime, duration: durationAnimation))
                switch type {
                case 0:
                    layerInstruction.setTransformRamp(fromStart: CGAffineTransform(translationX: 500, y: 0), toEnd: CGAffineTransform(translationX: 0, y: 0), timeRange: CMTimeRange.init(start: CMTime.zero, duration: durationAnimation))
                case 1:
                    layerInstruction.setTransformRamp(fromStart: CGAffineTransform(translationX: -500, y: 0), toEnd: CGAffineTransform(translationX: 0, y: 0), timeRange: CMTimeRange.init(start: CMTime.zero, duration: durationAnimation))
                case 2:
                    layerInstruction.setTransformRamp(fromStart: CGAffineTransform(translationX: 0, y: -600), toEnd: CGAffineTransform(translationX: 0, y: 0), timeRange: CMTimeRange.init(start: CMTime.zero, duration: durationAnimation))
                case 3:
                    layerInstruction.setTransformRamp(fromStart: CGAffineTransform(translationX: 0, y: 600), toEnd: CGAffineTransform(translationX: 0, y: 0), timeRange: CMTimeRange.init(start: CMTime.zero, duration: durationAnimation))
                case 4:
                    layerInstruction.setTransformRamp(fromStart: CGAffineTransform(translationX: -600, y: -600), toEnd: CGAffineTransform(translationX: 0, y: 0), timeRange: CMTimeRange.init(start: CMTime.zero, duration: durationAnimation))
                case 5:
                    layerInstruction.setTransformRamp(fromStart: CGAffineTransform(translationX: 600, y: 600), toEnd: CGAffineTransform(translationX: 0, y: 0), timeRange: CMTimeRange.init(start: CMTime.zero, duration: durationAnimation))
                case 6:
                    layerInstruction.setOpacityRamp(fromStartOpacity: 0.0, toEndOpacity: 1.0, timeRange: CMTimeRange.init(start: CMTime.zero, duration: durationAnimation))
                default:
                    break
                }
                layerInstruction.setOpacity(1, at: endTime)
                arrayLayerInstructions.append(layerInstruction)
                insertTime = CMTimeAdd(insertTime, duration)
            }
            catch {
                failure(error.localizedDescription)
            }
            
            
            // Main video composition instruction
            let mainInstruction = AVMutableVideoCompositionInstruction()
            mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: insertTime)
            mainInstruction.layerInstructions = arrayLayerInstructions
            
            // Main video composition
            let mainComposition = AVMutableVideoComposition()
            mainComposition.instructions = [mainInstruction]
            mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
            mainComposition.renderSize = outputSize
            
            //Create Directory path for Save
            if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count > 0{
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                var outputURL = documentDirectory.appendingPathComponent("\("TransitionVideo")\(randomString(length:10))")
                do {
                    try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                    outputURL = outputURL.appendingPathComponent("\(outputURL.lastPathComponent).m4v")
                }catch let error {
                    failure(error.localizedDescription)
                }
                
                //Remove existing file
                self.deleteFile(outputURL)
                
                //export the video to as per your requirement conversion
                if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
                    exportSession.outputURL = outputURL
                    exportSession.outputFileType = AVFileType.mp4
                    exportSession.shouldOptimizeForNetworkUse = true
                    exportSession.videoComposition = mainComposition
                    /// try to export the file and handle the status cases
                    exportSession.exportAsynchronously(completionHandler: {
                        switch exportSession.status {
                        case .completed :
                            success(outputURL)
                        case .failed:
                            if let _error = exportSession.error?.localizedDescription {
                                failure(_error)
                            }
                        case .cancelled:
                            if let _error = exportSession.error?.localizedDescription {
                                failure(_error)
                            }
                        default:
                            if let _error = exportSession.error?.localizedDescription {
                                failure(_error)
                            }
                        }
                    })
                } else {
                    failure("video export session failed")
                }
            }
        }
    }
    
    
    func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
    func videoCompositionInstructionForTrackWithSizeandTime(track: AVCompositionTrack, asset: AVAsset, standardSize:CGSize, atTime: CMTime) -> AVMutableVideoCompositionLayerInstruction {
        
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        if asset.tracks(withMediaType: AVMediaType.video).count > 0{
            let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
            
            let transform = assetTrack.preferredTransform
            let assetInfo = orientationFromTransform(transform)
            
            var aspectFillRatio:CGFloat = 1
            if assetTrack.naturalSize.height < assetTrack.naturalSize.width {
                aspectFillRatio = standardSize.height / assetTrack.naturalSize.height
            }
            else {
                aspectFillRatio = standardSize.width / assetTrack.naturalSize.width
            }
            
            if assetInfo.isPortrait {
                let scaleFactor = CGAffineTransform(scaleX: aspectFillRatio, y: aspectFillRatio)
                let posX = standardSize.width/2 - (assetTrack.naturalSize.height * aspectFillRatio)/2
                let posY = standardSize.height/2 - (assetTrack.naturalSize.width * aspectFillRatio)/2
                let moveFactor = CGAffineTransform(translationX: posX, y: posY)
                instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(moveFactor), at: atTime)
                
            } else {
                let scaleFactor = CGAffineTransform(scaleX: aspectFillRatio, y: aspectFillRatio)
                
                let posX = standardSize.width/2 - (assetTrack.naturalSize.width * aspectFillRatio)/2
                let posY = standardSize.height/2 - (assetTrack.naturalSize.height * aspectFillRatio)/2
                let moveFactor = CGAffineTransform(translationX: posX, y: posY)
                
                var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(moveFactor)
                
                if assetInfo.orientation == .down {
                    let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                    concat = fixUpsideDown.concatenating(scaleFactor).concatenating(moveFactor)
                }
                instruction.setTransform(concat, at: atTime)
            }
        }
        return instruction
    }
    
    //MARK: -- Copy video
    
    func copyVideo(from url: URL, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).count > 0{
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            var outputURL = documentDirectory.appendingPathComponent("\("MuteVideo")\(randomString(length:10)).mp4")
            let asset = AVAsset(url: url)
            
            //Remove existing file
            self.deleteFile(outputURL)
            let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
            exporter?.outputURL = outputURL
            exporter?.outputFileType = .mov
            exporter?.exportAsynchronously(completionHandler: {
                switch exporter?.status {
                case .completed:
                    success(outputURL)
                case .failed:
                    failure(exporter?.error?.localizedDescription)
                    
                case .cancelled:
                    failure(exporter?.error?.localizedDescription)
                    
                default:
                    failure(exporter?.error?.localizedDescription)
                }
            })
            //Remove existing file
        }
    }
    
    func getVideoComposition(asset : AVAsset) -> AVMutableComposition {
        // Create an AVMutableComposition for editing
        let mutableComposition = AVMutableComposition()
        // Get video tracks and audio tracks of our video and the AVMutableComposition
        let compositionVideoTrack = mutableComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        compositionVideoTrack?.preferredTransform = CGAffineTransform(rotationAngle: .pi / 3)
        
        let compositionAudioTrack = mutableComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        if asset.tracks(withMediaType: AVMediaType.video).count > 0{
            let videoTrack: AVAssetTrack  = asset.tracks(withMediaType: AVMediaType.video)[0]
            let audioTrack: AVAssetTrack  = asset.tracks(withMediaType: AVMediaType.audio)[0]
            
            // Add our video tracks and audio tracks into the Mutable Composition normal order
            do {
                try compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: videoTrack, at: CMTime.zero)
                try compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: audioTrack, at: CMTime.zero)
            } catch {
                return AVMutableComposition()
            }
        }
        return mutableComposition
    }
    
    func deleteFile(_ filePath:URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return
        }
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
}
