//
//  SelectWalletTableViewCell.swift
//  SwiftWallet
//
//  Created by Selin on 2018/3/21.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class SelectWalletTableViewCell: UITableViewCell {
     
    static let reuseIdentifier = "SelectWalletTableViewCell"

    @IBOutlet weak var walletIconImageView: UIImageView!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletNameButton: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
