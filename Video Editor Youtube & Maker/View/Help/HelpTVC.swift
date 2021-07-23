//
//  HelpTVC.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 12/28/20.
//

import UIKit

class HelpTVC: UITableViewCell {
    
    @IBOutlet weak var imgHinh: UIImageView!
    @IBOutlet weak var lblBody: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        imgHinh.layer.cornerRadius = 20
        lblTitle.layer.borderWidth = 2
        lblTitle.layer.cornerRadius = 10
        lblTitle.layer.borderColor = #colorLiteral(red: 0.9019607843, green: 0.7764705882, blue: 0.2901960784, alpha: 1)
    }
    
}
