//
//  HelpVC.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 12/25/20.
//

import UIKit

class HelpVC: UIViewController {
    
    @IBOutlet weak var tvcHelp: UITableView!
    @IBOutlet weak var lblName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        tvcHelp.delegate = self
        tvcHelp.dataSource = self
        tvcHelp.register(UINib(nibName: HelpTVC.className, bundle: nil), forCellReuseIdentifier: HelpTVC.className)
        tvcHelp.layer.cornerRadius = 10
        tvcHelp.backgroundColor = .clear
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
        self.dismiss(animated: true)
    }
    
}
extension HelpVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.font = UIFont(name: "Trebuchet MS Bold", size: 20)
            headerView.contentView.backgroundColor = .darkGray
            headerView.textLabel?.textColor = .white
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrHelpHeader.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return arrHelpHeader[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrHelpTile[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HelpTVC = tableView.dequeueReusableCell(withIdentifier: HelpTVC.className) as! HelpTVC
        cell.backgroundColor = .clear
        cell.lblTitle.text = arrHelpTile[indexPath.section][indexPath.row]
        cell.lblBody.text = arrHelpBody[indexPath.section][indexPath.row]
        cell.imgHinh.image = UIImage(named: arrHelpImage[indexPath.section][indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50 * scale
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400 * scale
    }
    
}
