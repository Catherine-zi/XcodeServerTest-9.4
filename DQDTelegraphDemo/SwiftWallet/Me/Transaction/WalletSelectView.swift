//
//  walletSelectView.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/12.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class WalletSelectView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    weak var tableDelegate: TransactionListViewController? {
        didSet {
            self.tableView.delegate = self.tableDelegate
            self.tableView.dataSource = self.tableDelegate
        }
    }
    
    typealias CloseBlock = () -> ()
    var closeBlock:CloseBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.layer.cornerRadius = 5;
        self.clipsToBounds = true
        
        Bundle.main.loadNibNamed("WalletSelectView", owner: self, options: nil)
        self.titleLabel.text = SWLocalizedString(key: "choose_wallet_dialog_title")
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib.init(nibName: "WalletSelectCell", bundle: nil), forCellReuseIdentifier: "walletSelectCell")
        
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        if self.closeBlock != nil {
            self.closeBlock!()
        }
    }
    
}
