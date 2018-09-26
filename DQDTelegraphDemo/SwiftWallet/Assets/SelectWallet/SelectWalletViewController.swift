//
//  SelectWalletViewController.swift
//  SwiftWallet
//
//  Created by Selin on 2018/3/21.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class SelectWalletViewController: UIViewController {

    @IBOutlet weak var WalletNameLabel: UILabel!
    @IBOutlet weak var manageWalletLabel: UILabel!

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var walletArr = NSArray()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.manageWalletLabel.text = SWLocalizedString(key: "manage_wallets")
        // Do any additional setup after loading the view.
        self.bgView.layer.cornerRadius = 4
        self.bgView.layer.shadowColor = UIColor.init(red: 30/255.0, green: 89/255.0, blue: 245/255.0, alpha: 0.3).cgColor
        self.bgView.layer.shadowOffset = CGSize.init(width: 5, height: 10)
        tableView.register(UINib.init(nibName: "SelectWalletTableViewCell", bundle:Bundle.main), forCellReuseIdentifier: SelectWalletTableViewCell.reuseIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonClick(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }

}


extension SelectWalletViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
}

extension SelectWalletViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectWalletTableViewCell.reuseIdentifier, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}









