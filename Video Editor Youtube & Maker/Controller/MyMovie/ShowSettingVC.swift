//
//  ShowSettingVC.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 12/30/20.
//

import UIKit

class ShowSettingVC: UIViewController {

    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var lblName: UILabel!
    
    var name: String = ""
    var body: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblName.text = name
        txtDescription.text = body
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
    
}
