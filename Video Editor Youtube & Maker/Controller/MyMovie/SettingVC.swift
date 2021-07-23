//
//  SettingVC.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 12/24/20.
//

import UIKit
import StoreKit

class SettingVC: UIViewController {

    @IBOutlet weak var viewBar: UIView!
    @IBOutlet weak var btnTerms: UIButton!
    @IBOutlet weak var btnPrivacy: UIButton!
    @IBOutlet weak var btnAbout: UIButton!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var lblName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewBar.layer.cornerRadius = 30
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_More(_ sender: Any) {
        SKStoreReviewController.requestReview()
    }
    
    @IBAction func btn_About(_ sender: Any) {
        self.showSuccess(message: "Do you like this app?")
    }
    
    @IBAction func btn_Privacy(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let show: ShowSettingVC = storyboard.instantiateViewController(withIdentifier: ShowSettingVC.className) as! ShowSettingVC
        show.name = "Privacy policy"
        show.body = privacy1 + "\n\n" + privacy2 + "\n\n" + privacy3 + "\n\n" + privacy4 + "\n\n" + privacy5 + "\n\n" + privacy6
        self.present(show, animated: true)
    }
    
    @IBAction func btn_Terms(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let show: ShowSettingVC = storyboard.instantiateViewController(withIdentifier: ShowSettingVC.className) as! ShowSettingVC
        show.name = "Terms"
        show.body = terms1 + "\n\n" + terms2 + "\n\n" + terms3 + "\n\n" + terms4 + "\n\n" + terms5 + "\n\n" + terms6 + "\n\n" + terms7 + "\n\n" + terms8 + "\n\n" + terms9 + "\n\n" + terms10 + "\n\n" + terms11
        self.present(show, animated: true)
    }
    
    
}
