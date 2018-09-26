//
//  WalletSelectCell.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/12.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class WalletSelectCell: UITableViewCell {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var chooseImgView: UIImageView!
    @IBOutlet weak var separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.backgroundColor = UIColor.init(hexColor: "1E59F5")
    }
    
    func setContent(model:SwiftWalletModel, isSelected:Bool) {
        if model.walletImage != nil {
            self.iconImgView.image = UIImage.init(named: model.walletImage!)
        }
        self.nameLbl.text = model.walletName
        if isSelected {
            self.chooseImgView.image = UIImage.init(named: "iconchosse")
            self.nameLbl.font = UIFont.boldSystemFont(ofSize: 12)
            self.nameLbl.textColor = UIColor.white
        } else {
            self.chooseImgView.image = UIImage.init(named: "iconnochosse")
            self.nameLbl.font = UIFont.systemFont(ofSize: 12)
            self.nameLbl.textColor = UIColor.init(white: 1, alpha: 0.4)
        }
    }
    
}
