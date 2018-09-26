//
//  TransactionDetailAddressCell.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/13.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class TransactionDetailAddressCell: UITableViewCell {

    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var fromTitleLbl: UILabel!
    @IBOutlet weak var toLbl: UILabel!
    @IBOutlet weak var toTitleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.fromTitleLbl.text = SWLocalizedString(key: "from")
        self.toTitleLbl.text = SWLocalizedString(key: "to")
    }

    func setContent(from:String, to:String) {
        self.fromLbl.text = from
        self.toLbl.text = to
    }
    
}
