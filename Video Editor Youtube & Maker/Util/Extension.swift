//
//  Extension.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 12/25/20.
//

import UIKit
import Foundation
import AVKit
import Photos
import MBProgressHUD
import Toast_Swift

let scaleH = DEVICE_HEIGHT / 896
let scaleW = DEVICE_WIDTH / 414

extension Date {
    static var currentTimeStamp: Int64 {
        return Int64(Date().timeIntervalSince1970)
    }
}

extension UIViewController {
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    func currentView() -> UIViewController{
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return (UIApplication.shared.keyWindow?.rootViewController)!
    }
    func showLoading(){
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
    }
    
    func hideLoading(){
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func showMessage(_ message: String) {
        DispatchQueue.main.async {
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = message
        }
    }
    

    func showSuccess(message: String){
        DispatchQueue.main.async {
            var style = ToastStyle()
            style.backgroundColor = UIColor.green.withAlphaComponent(1)
            style.messageColor = .black
            self.currentView().view.makeToast(message, duration: 3.0, position: .top, style: style)
        }
    }
    
    func showError(message: String){
        DispatchQueue.main.async {
            var style = ToastStyle()
            style.messageColor = .black
            style.backgroundColor = UIColor.red.withAlphaComponent(1)
            self.currentView().view.makeToast(message, duration: 3.0, position: .top, style: style)
        }
    }
    
}

extension NSObject {
    
    var className: String {
        
        return String(describing: type(of: self))
    }
    
    class var className: String {
        
        return String(describing: self)
    }
    
    func counter(assets: [[Any]]) -> Int{
        var count = 0
        for assets in assets{
            if assets.count > 1{
                count = count + assets.count - 1
            }
        }
        return count
    }
    
    func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
    func generateThumbnail(asset: AVAsset) -> UIImage? {
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        avAssetImageGenerator.appliesPreferredTrackTransform = true
        let thumnailTime = CMTimeMake(value: 2, timescale: 1)
        do {
            let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
            let thumbImage = UIImage(cgImage: cgThumbImage)
            return thumbImage
        } catch {
            return nil
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension PHAsset {
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

extension AVAsset {
    func generateThumbnail(completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let imageGenerator = AVAssetImageGenerator(asset: self)
            let time = CMTime(seconds: 0.0, preferredTimescale: 600)
            let times = [NSValue(time: time)]
            imageGenerator.generateCGImagesAsynchronously(forTimes: times, completionHandler: { _, image, _, _, _ in
                if let image = image {
                    completion(UIImage(cgImage: image))
                } else {
                    completion(nil)
                }
            })
        }
    }
}

extension UILabel {
    @IBInspectable var myAutoFontSize: Bool{
        get{ true }
        set {
            self.font = self.font.withSize(self.font.pointSize * scaleH)
        }
    }
    
    func durationtimeVideo(_ url: URL) {
        let asset = AVURLAsset(url: url)
        let durationInSeconds = asset.duration.seconds
        let secondString = String(format: "%02d", Int(durationInSeconds) % 60)
        let minutString = String(format: "%02d", Int(durationInSeconds) / 60)
        self.text = "\(minutString):\(secondString)"
    }
}

extension NSLayoutConstraint{
    @IBInspectable var myConstain: Bool {
        get { return true }
        set {
            let attribute = self.firstAttribute
            if attribute == .top || attribute == .bottom {
                self.constant = self.constant * scaleH
            } else if attribute == .leading || attribute == .trailing {
                self.constant = self.constant * scaleW
            } else if attribute == .width{
                self.constant = self.constant * scaleW
            } else if attribute == .height{
                self.constant = self.constant * scaleH
            }
        }
    }
}

extension UITextView{
    @IBInspectable var myAutoFontSize: Bool{
        get{ true }
        set {
            self.font = self.font?.withSize(self.font!.pointSize * scaleH)
        }
    }
}

extension UIButton{
    @IBInspectable var myAutoFontSize: Bool{
        get{ true }
        set {
            self.titleLabel?.font = self.titleLabel?.font.withSize((self.titleLabel?.font.pointSize)! * scaleH)
        }
    }
}

extension UIImage {
    func getSizeForVideo() -> CGSize {
        let scale = UIScreen.main.scale
        var imageWidth = 16 * ((size.width / scale) / 16).rounded(.awayFromZero)
        var imageHeight = 16 * ((size.height / scale) / 16).rounded(.awayFromZero)
        var ratio: CGFloat!
        
        if imageWidth > 1400 {
            ratio = 1400 / imageWidth
            imageWidth = 16 * (imageWidth / 16).rounded(.towardZero) * ratio
            imageHeight = 16 * (imageHeight / 16).rounded(.towardZero) * ratio
        }
        
        if imageWidth < 800 {
            ratio = 800 / imageWidth
            imageWidth = 16 * (imageWidth / 16).rounded(.awayFromZero) * ratio
            imageHeight = 16 * (imageHeight / 16).rounded(.awayFromZero) * ratio
        }
        
        if imageHeight > 1200 {
            ratio = 1200 / imageHeight
            imageWidth = 16 * (imageWidth / 16).rounded(.towardZero) * ratio
            imageHeight = 16 * (imageHeight / 16).rounded(.towardZero) * ratio
        }
        
        return CGSize(width: imageWidth, height: imageHeight)
    }
    func scaleImageToSize(newSize: CGSize) -> UIImage? {
        
        var scaledImageRect: CGRect = CGRect.zero
        
        let aspectWidth: CGFloat = newSize.width / size.width
        let aspectHeight: CGFloat = newSize.height / size.height
        let aspectRatio: CGFloat = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        
        scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if UIGraphicsGetCurrentContext() != nil {
            draw(in: scaledImageRect)
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return scaledImage
        }
        
        return nil
    }
    func resizeImageToVideoSize() -> UIImage? {
        let scale = UIScreen.main.scale
        let videoImageSize = getSizeForVideo()
        let imageRect = CGRect(x: 0, y: 0, width: videoImageSize.width * scale, height: videoImageSize.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageRect.width, height: imageRect.height), false, scale)
        if let _ = UIGraphicsGetCurrentContext() {
            draw(in: imageRect, blendMode: .normal, alpha: 1)
            
            if let resultImage = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                return resultImage
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
            let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
            let format = imageRendererFormat
            format.opaque = isOpaque
            return UIGraphicsImageRenderer(size: canvas, format: format).image {
                _ in draw(in: CGRect(origin: .zero, size: canvas))
            }
    }
    
}

extension AVURLAsset {
    var fileSize: Int? {
        let keys: Set<URLResourceKey> = [.totalFileSizeKey, .fileSizeKey]
        let resourceValues = try? url.resourceValues(forKeys: keys)

        return resourceValues?.fileSize ?? resourceValues?.totalFileSize
    }
}

extension String {
    public func toFloat() -> Float? {
        return Float.init(self)
    }
    
    public func toDouble() -> Double? {
        return Double.init(self)
    }
}


