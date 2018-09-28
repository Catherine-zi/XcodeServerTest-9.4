//
//  TotalCostCell.swift
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/7/31.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

protocol TotalCostCellDelegate: class {
    func costCellDidEndEditing(cell: TotalCostCell)
}

class TotalCostCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var imgBackView: UIView!
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var symbolLbl: UILabel!
    @IBOutlet weak var unitLbl: UILabel!
    @IBOutlet weak var amountField: UITextField!
    
    var asset: AssetsTokensModel?
    var assetIndex: Int?
    weak var costDelegate: TotalCostCellDelegate?
    
    var price = Decimal()
    var symbol: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.imgBackView.layer.borderColor = UIColor.init(hexColor: "f1f1f1").cgColor
        self.amountField.delegate = self
    }
    
    func setContent(wallet: SwiftWalletModel, assetIndex: Int) {
        self.assetIndex = assetIndex
        self.unitLbl.text = SwiftExchanger.shared.currency.rawValue
        if let assets = wallet.assetsType,
            assets.count > assetIndex {
            let asset = assets[assetIndex]
            
            self.asset = asset
            self.symbol = asset.symbol
            self.symbolLbl.text = asset.symbol
            if var price = asset.costPrice,
                let currency = asset.costCurrency
            {
                if currency != SwiftExchanger.shared.currency {
                    price = SwiftExchanger.shared.getConvertedCurrency(amount: price, from: currency, to: SwiftExchanger.shared.currency)
                }
                self.price = SwiftExchanger.shared.getRoundedNumber(number: price, decimalCount: 2)
                self.amountField.text = self.price.description
            }
            
            if let symbol = asset.symbol,
                let image = UIImage.init(named: symbol)
            {
                self.iconImgView.image = image
            } else {
                self.iconImgView.coinImageSet(urlStr: asset.iconUrl)
            }
            
//            if wallet.coinType == CoinType.BTC || asset.symbol == "ETH" {
//                let coinName = wallet.coinType?.rawValue
////                self.symbolLbl.text = coinName
//                if coinName != nil {
//                    self.iconImgView.image = UIImage.init(named: coinName!)
//                }
//            } else {
////                self.symbolLbl.text = asset.symbol
//                self.iconImgView.coinImageSet(urlStr: asset.iconUrl)
//            }
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text
        {
            if let price = Decimal(string: text) {
                self.asset?.costPrice = price
                self.asset?.costCurrency = SwiftExchanger.shared.currency
                self.asset?.cost = price
                self.price = price
            }
            if let asset = self.asset,
                let index = self.assetIndex
            {
                self.costDelegate?.costCellDidEndEditing(cell: self)
            }
        }
        return true
    }
    
}
