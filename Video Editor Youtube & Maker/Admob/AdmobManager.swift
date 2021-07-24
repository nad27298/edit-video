//
//  AdmobManager.swift
//  MangaReader
//
//  Created by Nhuom Tang on 9/9/18.
//  Copyright © 2018 Nhuom Tang. All rights reserved.
//

import UIKit
import GoogleMobileAds
import FBAudienceNetwork

enum adType: Int {
    case facebook
    case admob
}

enum clickType: Int {
    case facebook
    case admob
    case none
    case all
}

let adSize = UIDevice.current.userInterfaceIdiom == .pad ? kGADAdSizeBanner: kGADAdSizeBanner

class AdmobManager: NSObject, GADUnifiedNativeAdDelegate {
    
    static let shared = AdmobManager()
    
    var interstitial: GADInterstitial!
    //    var fbInterstitialAd: FBInterstitialAd!
    
    var isShowAds = false
    var counter = 1
    
    var adType: adType = .admob
    var clickType: clickType = .none
    var fullErrorType: clickType = .none
    var nativeType: adType = .facebook
    
    var fullRootViewController: UIViewController!
    
    //Native ads
    private var adLoader: GADAdLoader!
    var fbNativeAds: [FBNativeAd] = []
    var admobNativeAds: [GADUnifiedNativeAd] = []
    var loadErrorNativeAdmob = 0
    var loadErrorFullAdmob = 0
    
    var nativeFBIndex = 0
    var nativeAdmobIndex = 0
    
    var isTimer = true
    
    override init() {
        super.init()
        self.createAndLoadInterstitial()
        self.createAndLoadFbInterstitial()
        self.loadAllNativeAds()
        counter = numberToShowAd - 1
        if randomBool(){
            adType = .admob
            nativeType = .facebook
        }else{
            adType = .facebook
            nativeType = .admob
        }
    }
    
    func randomBool() -> Bool {
        return arc4random_uniform(2) == 0
    }
    
    func openRateView(){
        if #available(iOS 10.3, *) {
            //            SKStoreReviewController.requestReview()
        } else {
        }
    }
    
    func createBannerView(inVC: UIViewController) -> UIView{
        let witdh = DEVICE_WIDTH
        let frame = CGRect.init(x: (witdh - adSize.size.width)/2 , y: 0, width: adSize.size.width, height: adSize.size.height)
        let bannerView = GADBannerView.init(adSize: adSize)
        bannerView.adUnitID = admobBanner
        bannerView.rootViewController = inVC
        bannerView.delegate = self
        bannerView.frame = frame
        inVC.view.addSubview(bannerView)
        let request = GADRequest()
        bannerView.load(request)
        
        let tempView = UIView.init(frame: CGRect.init(x:0 , y: 0, width: DEVICE_WIDTH, height: adSize.size.height))
        tempView.addSubview(bannerView)
        return tempView
    }
    
    func createAndLoadFbInterstitial() {
        //        if PaymentManager.shared.isPurchaseRemoveAds() {
        //            return
        //        }
        //        self.fbInterstitialAd = FBInterstitialAd.init(placementID: fbKeyFull)
        //        self.fbInterstitialAd.delegate = self;
        //        self.fbInterstitialAd.load()
    }
    
    //    func createAndLoadInterstitial() {
    //        if loadErrorFullAdmob >= 1{
    //            return
    //        }
    //        if PaymentManager.shared.isPurchaseRemoveAds() {
    //            return
    //        }
    //        interstitial = GADInterstitial(adUnitID: admobFull)
    //        interstitial.delegate = self
    //        let request = GADRequest()
    //        interstitial.load(request)
    //    }
    
    func loadAllNativeAds(){
        if !isTimer {
            return
        }
        isTimer = false
        let _ = Timer.scheduledTimer(withTimeInterval: 70, repeats: false) { [weak self] (timer) in
            self?.isTimer = true
        }
        self.loadFBNativeAds()
        self.loadAdmobNativeAds()
    }
    
    func randoomNativeAds() -> Any?{
        if nativeType == .facebook{
            if fbNativeAds.count > 0{
                nativeType = .admob
                return getFBNativeAds()
            }else{
                return getAdmobNativeAds()
            }
        }
        
        if nativeType == .admob{
            if admobNativeAds.count > 0{
                nativeType = .facebook
                return getAdmobNativeAds()
            }else{
                return getFBNativeAds()
            }
        }
        return nil
    }
    
    func getFBNativeAds() -> FBNativeAd?{
        if PaymentManager.shared.isPurchase() {
            return nil
        }
        if fbNativeAds.count > nativeFBIndex{
            let item = fbNativeAds[nativeFBIndex]
            nativeFBIndex = nativeFBIndex + 1
            return item
        }
        return fbNativeAds.last
    }
    
    func getAdmobNativeAds() -> GADUnifiedNativeAd?{
        if PaymentManager.shared.isPurchase() {
            return nil
        }
        if admobNativeAds.count > nativeAdmobIndex{
            let item = admobNativeAds[nativeAdmobIndex]
            nativeAdmobIndex = nativeAdmobIndex + 1
            return item
        }
        return admobNativeAds.last
    }
    
    func loadAdmobNativeAds(){
        
        if loadErrorNativeAdmob >= 1{
            return
        }
        if PaymentManager.shared.isPurchase() {
            return
        }
        
        if nativeAdmobIndex > 0{
            if admobNativeAds.count > (nativeAdmobIndex){
                return
            }
        }
        
        print("loadAdmobNativeAds")
        adLoader = GADAdLoader(adUnitID: adNativeAd, rootViewController: fullRootViewController, adTypes: [GADAdLoaderAdType.unifiedNative], options: nil)
        adLoader.delegate = self
        let request = GADRequest()
        adLoader.load(request)
    }
    
    func loadFBNativeAds(){
        //        if PaymentManager.shared.isPurchaseRemoveAds() {
        //            return
        //        }
        //        if nativeFBIndex > 0{
        //            if fbNativeAds.count > (nativeFBIndex){
        //                return
        //            }
        //        }
        //        print("loadFBNativeAds")
        //        let loadNativeAds = FBNativeAd.init(placementID: fbKeyNative)
        //        loadNativeAds.delegate = self
        //        loadNativeAds.loadAd()
    }
    
    func logEvent(){
        if PaymentManager.shared.isPurchase() {
            return
        }
        counter = counter + 1
        if counter % 3 == 0 {
            if fullErrorType == .all{
                createAndLoadInterstitial()
                createAndLoadFbInterstitial()
            }else if fullErrorType == .facebook{
                createAndLoadFbInterstitial()
            }else if fullErrorType == .admob{
                createAndLoadInterstitial()
            }
            fullErrorType = .none
        }
        if  counter >= numberToShowAd {
            isShowAds = true
            //            if adType == .facebook{
            //                if clickType == .facebook{
            //                    if interstitial.isReady{
            //                        adType = .facebook
            //                        interstitial.present(fromRootViewController: fullRootViewController)
            //                        counter = 1
            //                    }else{
            //                        if fbInterstitialAd.isAdValid{
            //                            adType = .admob
            //                            fbInterstitialAd.show(fromRootViewController: fullRootViewController)
            //                            counter = 1
            //                        }
            //                    }
            //                }else{
            //                    if fbInterstitialAd.isAdValid{
            //                        adType = .admob
            //                        fbInterstitialAd.show(fromRootViewController: fullRootViewController)
            //                        counter = 1
            //                    }else{
            //                        if interstitial.isReady{
            //                            adType = .facebook
            //                            interstitial.present(fromRootViewController: fullRootViewController)
            //                            counter = 1
            //                        }
            //                    }
            //                }
            //            }else{
            if clickType == .admob{
                //                    if fbInterstitialAd.isAdValid{
                //                        adType = .admob
                //                        fbInterstitialAd.show(fromRootViewController: fullRootViewController)
                //                        counter = 1
                //                    }else{
                if interstitial.isReady{
                    adType = .facebook
                    interstitial.present(fromRootViewController: fullRootViewController)
                    counter = 1
                }
                //                    }
            }else{
                if interstitial.isReady{
                    adType = .facebook
                    interstitial.present(fromRootViewController: fullRootViewController)
                    counter = 1
                }else{
                    //                        if fbInterstitialAd.isAdValid{
                    //                            adType = .admob
                    //                            fbInterstitialAd.show(fromRootViewController: fullRootViewController)
                    //                            counter = 1
                    //                        }
                }
            }
            //            }
        }else{
            if isShowAds{
                isShowAds = false
                self.openRateView()
            }
        }
    }
    
    func forceShowAdd(){
        counter = numberToShowAd
        self.logEvent()
    }
}

// Admod a Son
//extension AdmobManager: GADBannerViewDelegate{
//
//    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
//        print("adViewDidReceiveAd")
//    }
//
//    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
//        print("didFailToReceiveAdWithError bannerView")
//    }
//}
//
//extension AdmobManager: GADInterstitialDelegate{
//
//    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
//        self.createAndLoadInterstitial()
//    }
//
//    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
//        print("didFailToReceiveAdWithError GADInterstitial")
//        if fullErrorType == .facebook{
//            fullErrorType = .all
//        }else{
//            fullErrorType = .admob
//        }
//        loadErrorFullAdmob = loadErrorFullAdmob + 1
//    }
//
//    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
//        print("interstitialDidReceiveAd")
//    }
//
//    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
//        if clickType == .facebook{
//            clickType = .all
//        }else{
//            clickType = .admob
//        }
//        if clickType == .all {
//            numberToShowAd = 10
//        }
//    }
//}
//
//extension AdmobManager: GADAdLoaderDelegate{
//
//    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
//        print("\(adLoader) failed with error: \(error.localizedDescription)")
//        loadErrorNativeAdmob = loadErrorNativeAdmob + 1
//    }
//}

extension AdmobManager: GADBannerViewDelegate {
    func loadBannerView(inVC: UIViewController) {
        let bannerView = GADBannerView.init(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        inVC.view.addSubview(bannerView)
        inVC.view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: inVC.bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: inVC.view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        bannerView.adUnitID = admobBanner
        bannerView.rootViewController = inVC
        bannerView.delegate = self
        let request = GADRequest()
        bannerView.load(request)
    }
    
    func loadBannerView2(inVC: UIViewController) {
        let bannerView = GADBannerView.init(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        inVC.view.addSubview(bannerView)
        inVC.view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .top,
                                relatedBy: .equal,
                                toItem: inVC.topLayoutGuide,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: inVC.view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        bannerView.adUnitID = admobBanner
        bannerView.rootViewController = inVC
        bannerView.delegate = self
        let request = GADRequest()
        bannerView.load(request)
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
}


extension AdmobManager: GADInterstitialDelegate {
    
    func createAndLoadInterstitial() {
        if PaymentManager.shared.isPurchase() {
            return
        } else {
            interstitial = GADInterstitial(adUnitID: admobFull)
            interstitial.delegate = self
            let request = GADRequest()
            interstitial.load(request)
        }
        
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.createAndLoadInterstitial()
    }
    
    func loadAdFull(inVC: UIViewController) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: inVC)
        }
    }
    
    //    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
    //        print("didFailToReceiveAdWithError GADInterstitial")
    //        if fullErrorType == .facebook{
    //            fullErrorType = .all
    //        }else{
    //            fullErrorType = .admob
    //        }
    //        loadErrorFullAdmob = loadErrorFullAdmob + 1
    //    }
    //
    //    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
    //        print("interstitialDidReceiveAd")
    //    }
    //
    //    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
    //        if clickType == .facebook{
    //            clickType = .all
    //        }else{
    //            clickType = .admob
    //        }
    //        if clickType == .all {
    //            numberToShowAd = 10
    //        }
    //    }
}

extension AdmobManager: GADVideoControllerDelegate {
    
    func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
        //videoStatusLabel.text = "Video playback has ended."
    }
}

extension AdmobManager: GADAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
    }
}

extension AdmobManager: GADUnifiedNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        print("didReceive nativeAd")
        admobNativeAds.append(nativeAd)
    }
}

extension AdmobManager: FBInterstitialAdDelegate{
    
    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        print("FB: interstitialAdDidLoad")
    }
    
    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        print("FB: didFailWithError \(error.localizedDescription)")
        if fullErrorType == .admob{
            fullErrorType = .all
        }else{
            fullErrorType = .facebook
        }
    }
    
    func interstitialAdWillClose(_ interstitialAd: FBInterstitialAd) {
        
    }
    
    func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
        print("FB: interstitialAdDidClose")
        createAndLoadFbInterstitial()
    }
    
    func interstitialAdDidClick(_ interstitialAd: FBInterstitialAd) {
        if clickType == .admob{
            clickType = .all
        }else{
            clickType = .facebook
        }
        if clickType == .all {
            numberToShowAd = 10
        }
    }
}

extension AdmobManager: FBNativeAdDelegate{
    
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        print("FB: nativeAdDidLoad")
        fbNativeAds.append(nativeAd)
    }
    
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        print("FB: didFailWithError \(error.localizedDescription)")
    }
}

