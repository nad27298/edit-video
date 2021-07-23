//
//  Utils.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 12/25/20.
//

import Foundation
import UIKit
import Photos
import AVKit
import MediaPlayer

var check: Int = 0
var defaultSize = CGSize(width: 1920, height: 1080)
let applemusicItems = MPMediaQuery.songs().items

var transitionItems = ["Right to Left","Left to Right","Top to Bottom","Bottom to Top", "Lefttop to Rightbottom","Rightbottom to Lefttop", "Fade in/out"]
var speedItems = ["0.25", "0.5", "0.75", "1.0", "1.25", "1.5"]
var positionItems = ["ButtonLeft","ButtonCenter","ButtonRight","CenterLeft","Center","CenterRight","TopLeft","TopCenter","TopRight"]
var CIEffectNames = [
    "CIComicEffect",
    "CIBloom",
    "CICrystallize",
    "CIPointillize",
    "CISpotColor",
    "CISpotLight",
    "CIBumpDistortion",
    "CIBumpDistortionLinear",
    "CIPixellate",
    "CICircleSplashDistortion",
    "CIGlassDistortion",
    "CIGlassLozenge",
    "CIHoleDistortion",
    "CILightTunnel",
    "CIPinchDistortion",
    "CITorusLensDistortion",
    "CITwirlDistortion",
    "CIVortexDistortion"
]
var CIFilterNames = [
    "CISharpenLuminance",
    "CIPhotoEffectChrome",
    "CIPhotoEffectFade",
    "CIPhotoEffectInstant",
    "CIPhotoEffectNoir",
    "CIPhotoEffectProcess",
    "CIPhotoEffectTonal",
    "CIPhotoEffectTransfer",
    "CISepiaTone",
    "CIColorClamp",
    "CIColorInvert",
    "CIColorMonochrome",
    "CISpotLight",
    "CIColorPosterize",
    "CIBoxBlur",
    "CIDiscBlur",
    "CIGaussianBlur",
    "CIMaskedVariableBlur",
    "CIMedianFilter",
    "CIMotionBlur",
    "CINoiseReduction"
]
var CIExposure = [
    "CIPixellate",
    "CICircleSplashDistortion",
    "CIGlassDistortion",
    "CIGlassLozenge",
    "CIHoleDistortion",
]
var CISharpen = [
    "CIColorPosterize",
    "CIBoxBlur",
    "CIDiscBlur",
    "CIGaussianBlur",
    "CIMaskedVariableBlur"
]
var CISaturation = [
    "CIEightfoldReflectedTile",
    "CIFourfoldReflectedTile",
    "CIFourfoldRotatedTile",
    "CIFourfoldTranslatedTile",
    "CIGlideReflectedTile"
]
var CIVignette = [
    "CIOpTile",
    "CIParallelogramTile",
    "CIPerspectiveTile",
    "CISixfoldReflectedTile",
    "CISixfoldRotatedTile"
]
var CIWhiteBlance = [
    "CICircularScreen",
    "CICMYKHalftone",
    "CIDotScreen",
    "CIHatchedScreen",
    "CILineScreen"
]
var CILightness = [
    "CIAffineTransform",
    "CILanczosScaleTransform",
    "CIPerspectiveCorrection",
    "CIPerspectiveTransform",
    "CIStraightenFilte"
]
var CIContrast = [
    "CIHoleDistortion",
    "CIPinchDistortion",
    "CITorusLensDistortion",
    "CITwirlDistortion",
    "CIVortexDistortion"
]
let arrColor: [UIColor] = [#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), #colorLiteral(red: 1, green: 0.2179800874, blue: 0.1397498585, alpha: 1), #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1), #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1), #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1), #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1), #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)]
let arrAudio = ["Audio1", "Audio2", "Audio3", "Audio4", "Audio5", "Audio6", "Audio7", "Audio8", "Audio9", "Audio10", "Audio11", "Audio12", "Audio13", "Audio14", "Audio15", "Audio16", "Audio17", "Audio18", "Audio19", "Audio20", "Audio21", "Audio22", "Audio23", "Audio24", "Audio25", "Audio26", "Audio27", "Audio28", "Audio29", "Audio30", "Audio31", "Audio32", "Audio33", "Audio34", "Audio35"]
let arrEffect = ["ComicEffect", "Bloom", "Crystallize", "Pointillize", "SpotColor", "SpotLight 2", "BumpDistortion", "BumpDistortionLinear", "Pixellate", "CircleSplashDistortion", "GlassDistortion", "GlassLozenge", "HoleDistortion", "LightTunnel", "PinchDistortion", "TorusLensDistortion", "TwirlDistortion", "VortexDistortion"]
let arrFilter = ["Luminance","Chrome","Fade","Instant","Noir","Process","Tonal","Transfer","Sepia Tone","Color Clamp","ColorInvert","Color Monochrome","Spot Light","Color Posterize","Box Blur","Disc Blur","Gaussian Blur","Masked Variable Blur","Median Filter","Motion Blur","Noise Reduction"]
let arrBG: [String] = ["BG_01", "BG_02", "BG_03", "BG_04", "BG_05", "BG_06", "BG_07", "BG_08", "BG_09", "BG_10", "BG_11", "BG_12", "BG_13", "BG_14", "BG_15", "BG_16", "BG_17", "BG_18", "BG_19", "BG_20", "BG_21", "BG_22", "BG_23", "BG_24"]
let arrScaleName: [String] = ["Original", "1:1", "4:5", "16:9", "9:16", "4:3"]
let arrScale: [String] = ["OriginalSize", "Size11", "Size45", "Size169", "Size916", "Size43"]
let arrImage: [String] = []
let arrGif: [String] = ["Gif"]
let arrThugLife: [String] = ["img_thuglife_01", "img_thuglife_02", "img_thuglife_03", "img_thuglife_04", "img_thuglife_05", "img_thuglife_06", "img_thuglife_07", "img_thuglife_08", "img_thuglife_09", "img_thuglife_10", "img_thuglife_11", "img_thuglife_12", "img_thuglife_13", "img_thuglife_14", "img_thuglife_15", "img_thuglife_16", "img_thuglife_17", "img_thuglife_18", "img_thuglife_19", "img_thuglife_20"]
let arrSanta: [String] = ["stanta_01", "stanta_02", "stanta_03", "stanta_04", "stanta_05", "stanta_06", "stanta_07", "stanta_08", "stanta_09", "stanta_10", "stanta_11", "stanta_12", "stanta_13", "stanta_14", "stanta_15", "stanta_16", "stanta_17", "stanta_18", "stanta_19", "stanta_20", "stanta_21", "stanta_22", "stanta_23"]
let arrSocks: [String] = ["socks_1", "socks_2", "socks_3", "socks_4", "socks_5", "socks_6", "socks_7", "socks_8", "socks_9", "socks_10", "socks_11", "socks_12", "socks_13", "socks_14", "socks_15", "socks_16", "socks_17", "socks_18", "socks_19", "socks_20"]
let arrSocial: [String] = ["social_00", "social_01", "social_02", "social_03", "social_04", "social_05", "social_06", "social_07", "social_08", "social_09", "social_10", "social_11", "social_12", "social_13", "social_14", "social_15", "social_16", "social_17", "social_18", "social_19", "social_20", "social_21", "social_22", "social_23", "social_24", "social_25", "social_26", "social_27", "social_28"]
let arrRainbow: [String] = ["rainbow_01", "rainbow_02", "rainbow_03", "rainbow_04", "rainbow_05", "rainbow_06", "rainbow_07", "rainbow_08", "rainbow_09", "rainbow_10", "rainbow_11", "rainbow_12", "rainbow_13", "rainbow_14", "rainbow_15", "rainbow_16", "rainbow_17", "rainbow_18", "rainbow_19", "rainbow_20", "rainbow_21"]
let arrNewYear: [String] = ["year_1", "year_2", "year_3", "year_4", "year_5", "year_6", "year_7", "year_8", "year_9", "year_10", "year_11", "year_12", "year_13", "year_14", "year_15", "year_16", "year_17", "year_18", "year_19", "year_20"]
let arrLove: [String] = ["love_01", "love_02", "love_03", "love_04", "love_05", "love_06", "love_07", "love_08", "love_09", "love_10", "love_11", "love_12", "love_13", "love_14", "love_15", "love_16", "love_17"]
let arrLight: [String] = ["img_light_01", "img_light_02", "img_light_03", "img_light_04", "img_light_05", "img_light_06", "img_light_07", "img_light_08", "img_light_09", "img_light_10", "img_light_11", "img_light_12", "img_light_13", "img_light_14", "img_light_15", "img_light_16", "img_light_17", "img_light_18", "img_light_19", "img_light_20", "img_light_21", "img_light_22"]
let arrIcon: [String] = ["001", "002", "003", "004", "005", "006", "007", "008", "009", "010", "011", "012", "013", "014", "015", "016", "017", "018", "019", "020", "021", "022", "023", "024", "025", "026", "027", "028", "029", "030"]
let arrGhost: [String] = ["ghost_01", "ghost_02", "ghost_03", "ghost_04", "ghost_05", "ghost_06", "ghost_07", "ghost_08", "ghost_09", "ghost_10", "ghost_11", "ghost_12", "ghost_13", "ghost_14", "ghost_15", "ghost_16", "ghost_17", "ghost_18", "ghost_19", "ghost_20", "ghost_21", "ghost_22", "ghost_23", "ghost_24"]
let arrFire: [String] = ["img_fire2_01", "img_fire2_02", "img_fire2_03", "img_fire2_04", "img_fire2_05", "img_fire2_06", "img_fire2_07", "img_fire2_08", "img_fire2_09", "img_fire2_10", "img_fire2_11", "img_fire2_12", "img_fire2_13", "img_fire2_14", "img_fire2_15", "img_fire2_16", "img_fire2_17", "img_fire2_18", "img_fire2_19", "img_fire2_20", "img_fire2_21"]
let arrEmoji: [String] = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16"]
let arrCmoji: [String] = ["img_01", "img_02", "img_03", "img_04", "img_05", "img_06", "img_07", "img_08", "img_09", "img_10", "img_11", "img_12", "img_13", "img_14", "img_15", "img_16", "img_17", "img_18", "img_19", "img_20", "img_21", "img_22", "img_23", "img_24", "img_25", "img_26"]
let arrABC: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
let arrBoom: [String] = ["boom_01", "boom_02", "boom_03", "boom_04", "boom_05", "boom_06", "boom_07", "boom_08", "boom_09", "boom_10", "boom_11", "boom_12", "boom_13", "boom_14", "boom_15", "boom_16", "boom_17", "boom_18", "boom_19", "boom_20"]
let arrAdjust1: [String] = ["Sharpen", "Exposure", "Contrast", "Lightness", "Saturation", "Vignette", "WhiteBlance"]
let arrItems: [String] = ["Adjust", "Edit", "Filter", "Effect", "Sticker", "Text", "Transition", "Music"]
let arrAdjust: [String] = ["Scale", "Background", "Color", "Adjust 1"]
let arrEdit: [String] = [ "Remove", "Speed", "Trim", "Mute", "Volumn", "Reverse", "Rotate", "Copy"]
let arrSticker: [String] = ["Image","Gif", "Emoji", "Cmoji", "Boom", "Socks", "ABC", "NewYear", "Santa", "Love", "Rainbow", "Social", "Ghost", "Light", "ThugLife", "Fire", "Icon"]
let arrMusic: [String] = ["Local", "AppleMusic", "Voiceover"]
let arrProTitle: [String] = ["Remove All ADs Automatically", "Remove Watermark", "Eye Catching Glitches", "Eye Catching Glitches", "Continuous Prodution"]
let arrProBody: [String] = ["All ads will be automatically removed. You will not be disturbed by ads when editing videos.", "Your videos will no longer have annoying watermarks. Make the video cleaner.", "You will get more premium glitches effects, movie effects, make theo video like a movie.", "You will get more premium glitches effects, movie effects, make theo video like a movie.", "Join Video Editor Youtube & Maker VIP will get more benefits. We will develop more advanced materials and premium features, so slay tuned."]
let arrProImage: [String] = ["ProImage1","ProImage2","ProImage3", "ProImage4", "ProImage5"]
let arrHelpHeader: [String] = ["⭐️ Change adjust", "⭐️ Add background or color", "⭐️ Add filter or effect", "⭐️ Add music local", "⭐️ Scale cut video", "⭐️ Scale speed video", "⭐️ Add sticker", "⭐️ Add text", "⭐️ Trim video", "⭐️ Add voice", "⭐️ Change volumn"]
let arrHelpTile: [[String]] = [["Step 1", "Step 2"], ["Step 1", "Step 2"], ["Step 1", "Step 2"], ["Step 1", "Step 2"], ["Step 1", "Step 2"], ["Step 1"], ["Step 1", "Step 2", "Step 3"], ["Step 1", "Step 2"], ["Step 1", "Step 2"], ["Step 1"], ["Step 1", "Step 2"]]
let arrHelpBody: [[String]] = [["Click Adjust", "Change slider, pick adjust and click TICK to change"], ["Click Background or Color", "Select background image or color and TICK to add"], ["Click Filter or Effect", "Select filter or effect and TICK to add"], ["Click Music, select Local or AppleMusic", "Select audio file and TICK to add"], ["Click Scale", "Select scale value and TICK to change"], ["Click Speed, select speed value and click TICK to change"], ["Click Sticker, click sticker value", "Select sticker name", "Select position and TICK to add"], ["Click Text and add text", "Select positon and TICK to add"], ["Click Trim", "Scale time value and TICK to trim"], ["Click Voice to record audio voice and TICK to add"], ["Click Volume", "Change slider volum value and TICK to change"]]
let arrHelpImage: [[String]] = [["Adjust1", "Adjust2"], ["Color1", "Color2"], ["Filter1", "Filter2"], ["Local1", "Local2"], ["Scale1", "Scale2"], ["Speed1"], ["Sticker1", "Sticker2", "Sticker3"], ["Text1", "Text2"], ["Trim1", "Trim2"], ["Voice1"], ["Volume1", "Volume2"]]
let privacy1 = "Protecting your privacy is important to us. We hope the following statement will help you understand how MyMovie deals with the personal identifiable information ('PII') you may occasionally provide to us via Internet (the'Google Play'Platform)."
let privacy2 = "Generally, we do not collect any PII from you when you download our Android applications. To be specific, we do not require the consumers to get registered before downloading the application, nor do we keep track of the consumers' visits of our application, we even don't have a Server to store such PII."
let privacy3 = "Ads- MyMovie may use some providers to show ads. These Ads providers use Cookie only to identify your device, then show ads that are relevant to our app's kind. We don't share any users' data with Facebook or other parties(Verified by BBC & Privacy International)."
let privacy4 = "The only situation we may get access to your PII is when you personally decide to email us your feedback or to provide us with a bug report. The PII we may get from you in that situation are strictly limited to your name, email address and your survey response only."
let privacy5 = "In above situation, we guarantee that your PII will only be used for contacting you and improving our services. We will never use such information (e.g. your name and email address) for any other purposes, such as to further market our products, or to disclose your personal information to a third party for commercial gains.s"
let privacy6 = "It should be noted that whether or not to send us your feedback or bug report is a completely voluntary initiative upon your own decision. If you have concern about your PII being misused, or if you want further information about our privacy policy and what it means, please feel free to email us at charmernewapps@gmail.com, we will endeavor to provide clear answers to your questions in a timely manner"
let terms1 = "These terms and conditions outline the rules and regulations for the use of MyMovie."
let terms2 = "By accessing to the Service, we assume you accept these terms and conditions in full. You may not use MyMovie if you do not accept all of the terms and conditions stated on this page."
let terms3 = "Basic Introduction: In order to use the service or access the content, you are agreeing to the following terms and conditions. MyMovie does NOT claim ANY ownership rights in the text, files, images, photos, video, sounds, musical works, works of authorship, or any other materials (collectively, Content) that you created, you are solely responsible for all the Content that you create using the Service. It is your responsibility to make sure your use of the Services is legal where you use them. And you retain the rights to all the Content you created."
let terms4 = "Modifications to These Terms: MyMovie reserves the right to alter these Terms at any time in its sole discretion. When we make material changes to the Terms, we’ll provide you with prominent notice in appropriate way, please make sure you have read the notice in advance carefully. Your continued use of the MyMovie Services after such notification of changes to the Terms will constitute your agreement and acceptance to such changes. You may stop using the Service under the new version of these Terms if you object to the changes."
let terms5 = "Music Restritions: When uses choose to add online music, users must be sure of writing the name, which includes music and musician & URL: https://icons8.com/music/."
let terms6 = "Copyright and Trademarks: The Services provides users with the ability to create Content owned by yourselves. MyMovie will not have any ownership rights in the works you created. You represent and warrant that you own the Content created by you. However, the Service and its original Content (“MyMovie Content”) is protected by copyright, trademark, patent, trade secret and other laws. MyMovie owns and retains all rights in the MyMovie Content and the MyMovie Services."
let terms7 = "Disclaimer of Warranty: MyMovie Service is provided “AS IS” AND “AS AVAILABLE”, without express or implied warranty or condition of any kind. you use the MyMovie Service at your own risk. To the fullest extent permitted by applicable law, MyMovie and all owners of the content make no representations and disclaim any warranties or conditions of satisfactory quality, merchantability, fitness for a particular purpose, or non-infringement."
let terms8 = "Limitations of Liability: In no event shall MyMovie be liable for any loss or damages (including without limitation of any direct, indirect, punitive, special, incidental or consequential loss or damage): - Access to the Service or inability to access to the Service; -Any third party's conduct, content, information or data; - Personal injury or property damage, of any nature whatsoever, resulting from your access to and/or use of (or your inability to access and use) the MyMovie Services, including, without limitation, making private content public or any damage caused to your computer or software or information stored thereon; - Any unauthorized access to or use of MyMovie Services and/or any and all personal, private, and/ or other information stored therein."
let terms9 = "Thank You: Thank you for reading our Terms. Hope you enjoy editing with MyMovie!"
let terms10 = "Support and Contact: If you have any questions concerning the Service or the Terms, please contact us by email at charmernewapps@gmail.app."
let terms11 = "*This Terms has translations in other languages. If there is any doubt, the English version shall prevail."

class Utils {
    
    static let shared = Utils()
    
            
    func getNotiAlert(_ tilte: String,_ message: String,_ inVC: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: tilte, message: message, preferredStyle: .alert)
        let btn_OK: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(btn_OK)
        inVC.present(alert, animated: true, completion: nil)
    }
    
    func getErrorAlert(_ tilte: String,_ message: String,_ inVC: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: tilte, message: message, preferredStyle: .alert)
        let colerTitle = [NSAttributedString.Key.foregroundColor : UIColor.red]
        let titleAttrString = NSMutableAttributedString(string: tilte, attributes: colerTitle)
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        let btn_OK: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(btn_OK)
        inVC.present(alert, animated: true, completion: nil)
    }
    
    
    /*
    func generateThumbnail(path: URL) -> UIImage? {
    do {
    let asset = AVURLAsset(url: path, options: nil)
    let imgGenerator = AVAssetImageGenerator(asset: asset)
    imgGenerator.appliesPreferredTrackTransform = true
    let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 10, timescale: 1), actualTime: nil)
    let thumbnail = UIImage(cgImage: cgImage)
    return thumbnail
    } catch let error {
    print("*** Error generating thumbnail: \(error.localizedDescription)")
    return nil
    }
    }
    */
    
    
    /*
    func fetchVideos(_ asset: PHAsset) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d ", PHAssetMediaType.video.rawValue )
        let imageManager = PHCachingImageManager()
        imageManager.requestAVAsset(forVideo: asset, options: nil, resultHandler: { (asset, audioMix, info) in
            if asset != nil {
                let avasset = asset as! AVURLAsset
                let urlVideo = avasset.url
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.player = AVPlayer(url: urlVideo)
                    let playerLayer = AVPlayerLayer(player: self.player)
                    playerLayer.frame = self.viewVideos.bounds
                    self.viewVideos.layer.addSublayer(playerLayer)
                    self.player.play()
                }
            }
        })
    }
    
     func getURLVideo(_ asset: PHAsset) {
     let fetchOptions = PHFetchOptions()
     fetchOptions.predicate = NSPredicate(format: "mediaType = %d ", PHAssetMediaType.video.rawValue )
     let imageManager = PHCachingImageManager()
     imageManager.requestAVAsset(forVideo: asset, options: nil, resultHandler: { (asset, audioMix, info) in
     if asset != nil {
     let avasset = asset as! AVURLAsset
     let urlVideo = avasset.url
     self.url = urlVideo
     }
     })
     }
    
    func getAllFrames(_ url: URL) {
        let asset:AVAsset = AVAsset(url: url)
        let duration:Float64 = CMTimeGetSeconds(asset.duration)
        self.generator = AVAssetImageGenerator(asset:asset)
        self.generator.appliesPreferredTrackTransform = true
        self.frames = []
        for index:Int in 0 ..< Int(duration) {
            self.getFrame(fromTime:Float64(index))
        }
        self.generator = nil
    }
    
    private func getFrame(fromTime:Float64) {
        let time:CMTime = CMTimeMakeWithSeconds(fromTime, preferredTimescale:600)
        let image:CGImage
        do {
            try image = self.generator.copyCGImage(at:time, actualTime:nil)
        } catch {
            return
        }
        self.frames.append(UIImage(cgImage:image))
    }
    */
    
}
