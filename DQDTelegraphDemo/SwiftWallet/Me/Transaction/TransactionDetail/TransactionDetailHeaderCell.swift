//
//  TransactionDetailHeaderCell.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/13.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class TransactionDetailHeaderCell: UITableViewCell {

    @IBOutlet weak var stateImgView: UIImageView!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var unitLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    func setContent(data:UniversalTransactionModel) {
        var changeChar = ""
        if data.isIn != nil {
            if data.isIn! {
                changeChar = "+ "
            } else {
                changeChar = "- "
            }
        }
        if data.amount != nil {
            self.amountLbl.text = changeChar + data.amount!.description
        }
        if data.coinType != nil {
            if data.coinType == CoinType.ETH {
                self.unitLbl.text = data.assetSymbol
            } else {
                self.unitLbl.text = data.coinType!.rawValue
            }
        }
        let formatter: DateFormatter = DateFormatter()
        formatter.locale = NSLocale(localeIdentifier: TelegramUserInfo.shareInstance.currentLanguage) as Locale?
        formatter.dateFormat = SWLocalizedString(key: "date_formatter")
        if data.timeInterval != nil {
            self.timeLbl.text = formatter.string(from: Date(timeIntervalSince1970: data.timeInterval!))
        } else {
            self.timeLbl.text = data.time
        }
        var stateImgStr = ""
        if data.state == 1 {
            stateImgStr = "iconsucc"
        } else if data.state == 2 {
            stateImgStr = "iconwaiting"
        } else if data.state == 3 {
            stateImgStr = "iconfail"
        }
        self.stateImgView.image = UIImage.init(named: stateImgStr)
    }
    
}
