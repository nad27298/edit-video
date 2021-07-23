//
//  AdjustSliderCVC.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 1/16/21.
//

import UIKit

protocol SmartDelegate: class {
    func updateAnswer(_ answer: String)
}

class AdjustSliderCVC: UICollectionViewCell {
    
    var checkSld: Int = 0
    var adjustFilter = ""
    
    @IBOutlet weak var sldAdjust: UISlider! {
        didSet {
            sldAdjust.transform = CGAffineTransform(rotationAngle: -(.pi / 2))
        }
    }
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgHinh: UIImageView!
    
    weak var delegate: SmartDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    @IBAction func sld_Adjust(_ sender: UISlider) {
        switch checkSld {
        case 0:
            adjustFilter = CISharpen[Int(sender.value)]
            delegate?.updateAnswer(adjustFilter)
        case 1:
            adjustFilter = CIExposure[Int(sender.value)]
            delegate?.updateAnswer(adjustFilter)
        case 2:
            adjustFilter = CIContrast[Int(sender.value)]
            delegate?.updateAnswer(adjustFilter)
        case 3:
            adjustFilter = CILightness[Int(sender.value)]
            delegate?.updateAnswer(adjustFilter)
        case 4:
            adjustFilter = CISaturation[Int(sender.value)]
            delegate?.updateAnswer(adjustFilter)
        case 5:
            adjustFilter = CIVignette[Int(sender.value)]
            delegate?.updateAnswer(adjustFilter)
        case 6:
            adjustFilter = CIWhiteBlance[Int(sender.value)]
            delegate?.updateAnswer(adjustFilter)
        default: break
        }
    }
    
}
