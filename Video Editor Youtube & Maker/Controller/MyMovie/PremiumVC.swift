//
//  PremiumVC.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 12/25/20.
//

import UIKit
import SwiftyStoreKit
import GoogleMobileAds
import StoreKit
import MBProgressHUD

enum PurchaseType: Int {
    case weekly
    case monthly
    case yearly
}

class PremiumVC: UIViewController {
    var purchaseType: PurchaseType = .yearly

    @IBOutlet weak var txtview: UITextView!
    @IBOutlet weak var lblSub: UILabel!
    @IBOutlet weak var imgHinh: UIImageView!
    @IBOutlet weak var lblBody: UILabel!
    @IBOutlet weak var btnRestore: UIButton!
    @IBOutlet weak var lblName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func purchasePro(type: PurchaseType){
        var productId = PRODUCT_ID_YEARLY
        if type == .yearly {
            productId = PRODUCT_ID_YEARLY
        }
        SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: false) { result in
            switch result {
            case .success(let product):
                // fetch content from your server, then:
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                let dateFormatter : DateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss"
                let date = Date()
                _ = dateFormatter.string(from: date)
                let interval = date.timeIntervalSince1970
                PaymentManager.shared.savePurchase(time: interval)
                print("Purchase Success: \(product.productId)")
                let fastCleanVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: MyMovieVC.className) as! MyMovieVC
                self.navigationController?.pushViewController(fastCleanVC, animated: true)
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            }
        }
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btn_Restore(_ sender: Any) {
        SwiftyStoreKit.restorePurchases(atomically: false) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                for purchase in results.restoredPurchases {
                    // fetch content from your server, then:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                }
                let dateFormatter : DateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss"
                let date = Date()
                _ = dateFormatter.string(from: date)
                let interval = date.timeIntervalSince1970
                PaymentManager.shared.savePurchase(time: interval)
//                print("Purchase Success: \(product.productId)")
                let fastCleanVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: MyMovieVC.className) as! MyMovieVC
                self.navigationController?.pushViewController(fastCleanVC, animated: true)
            }
            else {
                print("Nothing to Restore")
            }
        }
    }

    @IBAction func btn_Month(_ sender: Any) {
        purchaseType = .monthly
        self.purchasePro(type: .monthly)
    }
    
    @IBAction func btn_All(_ sender: Any) {
    }
    
    @IBAction func btn_Year(_ sender: Any) {
        purchaseType = .yearly
        self.purchasePro(type: .yearly)
    }
}
