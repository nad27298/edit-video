//
//  PaymentManager.swift
//  MasterCleaner
//
//  Created by Nhuom Tang on 7/15/19.
//  Copyright © 2019 Nhuom Tang. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

enum FreeType: Int{
    case none
    case expried
    case free
}

class PaymentManager: NSObject {
    
    var isVerifyError = true
    
    static let shared = PaymentManager()
  
    func isPurchase()->Bool{
        if let time = KeychainWrapper.standard.double(forKey: "NGUYEN_HUY_SON"){
            let timeInterval = Date().timeIntervalSince1970
            if timeInterval > time{
                return false
            }
            return true
        }
        return false
    }
    
    func savePurchase(time: TimeInterval){
        KeychainWrapper.standard.set(time, forKey: "NGUYEN_HUY_SON")
    }
   
}
