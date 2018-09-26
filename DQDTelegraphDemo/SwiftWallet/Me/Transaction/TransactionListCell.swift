//
//  TransactionListCell.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/12.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class TransactionListCell: UITableViewCell {

    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var transIdLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var coinLogoView: UIImageView!
    @IBOutlet weak var coinNameLbl: UILabel!
    @IBOutlet weak var changeView: UIView!
    @IBOutlet weak var changeLbl: UILabel!
    
    let greenColor = UIColor.init(hexColor: "78DA78")
    let redColor = UIColor.init(hexColor: "F96C6C")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.backgroundColor = UIColor.init(hexColor: "F2F2F2")
    }
    
    func setContent(data:TransactionListViewController.UniversalTransactionModel) {
        let changeValue:Decimal = data.amount ?? 0.0
        var iconImg = ""
        var changeColor = UIColor.white
        var changeChar = ""
        var address: String?
        if data.isIn != nil {
            if data.isIn! {
                iconImg = "iconinwallet"
                changeColor = GainsUpColor
                changeChar = "+ "
                address = data.from
            } else {
                iconImg = "iconoutwallet"
                changeColor = GainsDownColor
                changeChar = "- "
                address = data.to
            }
        }
        self.iconImgView.image = UIImage.init(named: iconImg)
        self.transIdLbl.text = address
        if data.timeInterval != nil {
            self.timeLbl.text = data.timeInterval!.getFormattedString()
        }
        self.changeLbl.text = changeChar + changeValue.description
        self.changeView.backgroundColor = changeColor
        if data.coinType == CoinType.BTC || data.assetSymbol == "ETH" {
            let coinName = data.coinType?.rawValue
            self.coinNameLbl.text = coinName
            if coinName != nil {
                self.coinLogoView.image = UIImage.init(named: coinName!)
            }
        } else {
            self.coinNameLbl.text = data.assetSymbol ?? ""
            self.coinLogoView.coinImageSet(urlStr: data.assetIconUrl)
        }
    }

//    func setBtcContent(data:BtcTransactionModel) {
//        let changeValue = data.amount ?? 0.0
//        let isIn:Bool = changeValue > 0
//        var iconImg = ""
//        var changeColor = UIColor.white
//        var changeChar = ""
//        if isIn {
//            iconImg = "iconinwallet"
//            changeColor = greenColor
//            changeChar = "+"
//        } else {
//            iconImg = "iconoutwallet"
//            changeColor = redColor
//            changeChar = "-"
//        }
//        self.iconImgView.image = UIImage.init(named: iconImg)
//        self.transIdLbl.text = data.txid!
//        self.timeLbl.text = data.blocktime
//        self.changeLbl.text = changeChar + " " + String.init(format: "%0.2f", changeValue)
//        print(changeValue)
//        self.changeView.backgroundColor = changeColor
//        let coinName = "BTC"
//        self.coinNameLbl.text = coinName
//        self.coinLogoView.image = UIImage.init(named: coinName + "_logo")
//    }
//
//    func setEthContent(data:EthTransactionListDataModel) {
//        let changeValue = data.value ?? "0.0"
//        let isIn:Bool = Double(changeValue)! > 0
//        var iconImg = ""
//        var changeColor = UIColor.white
//        var changeChar = ""
//        if isIn {
//            iconImg = "iconinwallet"
//            changeColor = greenColor
//            changeChar = "+"
//        } else {
//            iconImg = "iconoutwallet"
//            changeColor = redColor
//            changeChar = "-"
//        }
//        self.iconImgView.image = UIImage.init(named: iconImg)
//        self.transIdLbl.text = data.ID!
//        self.timeLbl.text = data.timestamp
//        self.changeLbl.text = changeChar + " " + String.init(format: "%0.2f", changeValue)
//        print(changeValue)
//        self.changeView.backgroundColor = changeColor
//        let coinName = "ETH"
//        self.coinNameLbl.text = coinName
//        self.coinLogoView.image = UIImage.init(named: coinName + "_logo")
//    }
    
}
