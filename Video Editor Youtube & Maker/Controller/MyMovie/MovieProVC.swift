//
//  MovieProVC.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 12/24/20.
//

import UIKit
import GoogleMobileAds
import FBAudienceNetwork

class MovieProVC: UIViewController {

    @IBOutlet weak var tvcMoviePro: UITableView!
    @IBOutlet weak var lblName: UILabel!
    
    var fbNativeAds: FBNativeAd?
    var admobNativeAds: GADUnifiedNativeAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tvcMoviePro.delegate = self
        tvcMoviePro.dataSource = self
        tvcMoviePro.backgroundColor = .clear
        tvcMoviePro.layer.cornerRadius = 30
        tvcMoviePro.register(UINib(nibName: MovieProTVC.className, bundle: nil), forCellReuseIdentifier: MovieProTVC.className)
        tvcMoviePro.register(UINib(nibName: nativeAdmobTBLCell.className, bundle: nil), forHeaderFooterViewReuseIdentifier: nativeAdmobTBLCell.className)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if PaymentManager.shared.isPurchase(){
            
        } else {
            AdmobManager.shared.loadAdFull(inVC: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if PaymentManager.shared.isPurchase(){
            if fbNativeAds != nil{
                fbNativeAds = nil
                tvcMoviePro.reloadData()
            }
            if admobNativeAds != nil{
                admobNativeAds = nil
                tvcMoviePro.reloadData()
            }
        } else{
            if let native = AdmobManager.shared.randoomNativeAds(){
                if native is FBNativeAd{
                    fbNativeAds = native as? FBNativeAd
                    admobNativeAds = nil
                }else{
                    admobNativeAds = native as? GADUnifiedNativeAd
                    fbNativeAds = nil
                }
                tvcMoviePro.reloadData()
            }
        }
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btn_GotoSub(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let premium:PremiumVC = storyboard.instantiateViewController(withIdentifier: PremiumVC.className) as! PremiumVC
        self.present(premium, animated: true)
    }
    
}

extension MovieProVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: nativeAdmobTBLCell.className) as! nativeAdmobTBLCell
        if let native = self.admobNativeAds {
            headerView.setupHeader(nativeAd: native)
        }
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if fbNativeAds == nil && admobNativeAds == nil{
            return 0
        }
        return 160 * scale
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrProTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MovieProTVC = tableView.dequeueReusableCell(withIdentifier: MovieProTVC.className) as! MovieProTVC
        cell.backgroundColor = .clear
        cell.imgHinh.layer.cornerRadius = 20
        cell.lblTitle.text = arrProTitle[indexPath.row]
        cell.lblBody.text = arrProBody[indexPath.row]
        cell.imgHinh.image = UIImage(named: arrProImage[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tvcMoviePro.frame.width - (84 * scale)
    }
}
