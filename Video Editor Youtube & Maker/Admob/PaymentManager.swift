//
//  PaymentManager.swift
//  MasterCleaner
//
//  Created by Nhuom Tang on 7/15/19.
//  Copyright © 2019 Nhuom Tang. All rights reserved.
//

import UIKit
enum FreeType: Int{
    case none
    case expried
    case free
}

class PaymentManager: NSObject {
    
    var isVerifyError = true
    
    static let shared = PaymentManager()
  
    func isPurchase()->Bool{
        if let time = UserDefaults.standard.value(forKey: "purchaseTime") as? TimeInterval{
            let timeInterval = Date().timeIntervalSince1970
            if timeInterval > time{
                return false
            }
            return true
        }
        return false
    }
    
    func savePurchase(time: TimeInterval){
        UserDefaults.standard.setValue(time, forKey: "purchaseTime")
    }
   
}
