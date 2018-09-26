//
//  AllTableViewCell.swift
//  SwiftWallet
//
//  Created by Selin on 2018/4/9.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

protocol AllDataFavoritesButtonActionDelegate {
    func allDataFavoritesButtonAction(indexPath: IndexPath)
}

class AllTableViewCell: MGSwipeTableCell {

//    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var coinImageView: UIImageView!
    @IBOutlet weak var coinNameLabel: UILabel!
//    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var volPriceLabel: UILabel!
    @IBOutlet weak var volLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var increaseLabel: UILabel!

    private var allDataModel: MarketsAllDataStruct?
    private var indexPath_favor: IndexPath?
    var delegate_favor: AllDataFavoritesButtonActionDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func reuseIdentifier() -> String {
        return "AllTableViewCell"
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func fillDataWithSymbolStruct(detailStruct: MarketsAllDataStruct, indexPath: IndexPath) {
       allDataModel = detailStruct
        indexPath_favor = indexPath
        self.backgroundColor = Int(indexPath.row%2) == 1 ? UIColor.init(hexColor: "F8F8F8") : UIColor.white
//        self.numLabel.text = String(detailStruct.id!)
        self.coinNameLabel.text = detailStruct.symbol
		
        var temp: Int = 0
        var temp2: Int = 0
        var appendStr: String = ""
        
        if let marketCapUsd: String = detailStruct.marketCapUsd, let marketCapUsd_dec = Decimal(string: marketCapUsd) {
            let marketConverted = (marketCapUsd_dec / SwiftExchanger.shared.currencyRateToDollar).description
            let marketCapArr = marketConverted.components(separatedBy: ".")
            var marketCap: String = marketCapArr.first!
            if marketCap.count > 4 {
                if marketCap.count > 9 {
                    temp = 9
                    temp2 = 6
                    appendStr = "B"
                } else if marketCap.count > 6 {
                    temp = 6
                    temp2 = 3
                    appendStr = "M"
                } else if marketCap.count > 3 {
                    temp = 3
                    temp2 = 1
                    appendStr = "K"
                }
                let index = marketCap.index(marketCap.startIndex, offsetBy: marketCap.count-temp)
                let insertStr1 = marketCap.count-temp == 0 ? "0." : "."
                marketCap.insert(contentsOf:insertStr1, at:index)
                let index2 = marketCap.index(marketCap.startIndex, offsetBy: marketCap.count-temp2)
                let subMarketCapStr = marketCap.prefix(upTo: index2)
                let marketCapStr = subMarketCapStr.appending(appendStr)
                let decim = Decimal(string: marketCapStr) ?? Decimal()
                self.volPriceLabel.text = SwiftExchanger.shared.currencySymbol + SwiftExchanger.shared.getFormattedNumber(number: decim).description + appendStr
            } else {
                let decim = Decimal(string: marketCap) ?? Decimal()
                self.volPriceLabel.text = SwiftExchanger.shared.currencySymbol + SwiftExchanger.shared.getFormattedNumber(number: decim).description
            }
        }
        
        if let volumeUsd = detailStruct.volumeUsd, let volumeUsd_dec = Decimal(string: volumeUsd) {
            let volumeConverted = (volumeUsd_dec / SwiftExchanger.shared.currencyRateToDollar).description
            let volumeUsdArr = volumeConverted.components(separatedBy: ".")
            var volumeUsd: String = volumeUsdArr.first!
            if volumeUsd.count > 3 {
                if volumeUsd.count > 9 {
                    temp = 9
                    temp2 = 6
                    appendStr = "B"
                } else if volumeUsd.count > 6 {
                    temp = 6
                    temp2 = 3
                    appendStr = "M"
                } else if volumeUsd.count > 3 {
                    temp = 3
                    temp2 = 1
                    appendStr = "K"
                }
                let volumeUsdIndex = volumeUsd.index(volumeUsd.startIndex, offsetBy: volumeUsd.count-temp)
                let insertStr2 = volumeUsd.count-temp == 0 ? "0." : "."
                volumeUsd.insert(contentsOf: insertStr2, at: volumeUsdIndex)
                let volumeUsdIndex2 = volumeUsd.index(volumeUsd.startIndex, offsetBy: volumeUsd.count-temp2)
                let subVolumeUsdStr = volumeUsd.prefix(upTo: volumeUsdIndex2)
                let volumeUsdStr = subVolumeUsdStr.appending(appendStr)
                let decim = Decimal(string: volumeUsdStr) ?? Decimal()
                self.volLabel.text = SWLocalizedString(key: "volume_text") + SwiftExchanger.shared.getFormattedNumber(number: decim).description + appendStr
            } else {
                let decim = Decimal(string: volumeUsd) ?? Decimal()
                self.volLabel.text = SWLocalizedString(key: "volume_text") + SwiftExchanger.shared.getFormattedNumber(number: decim).description
            }
        }
        
        if let priceUsd = detailStruct.priceUsd, let priceUsd_dec = Decimal(string: priceUsd) {
            let price = priceUsd_dec / SwiftExchanger.shared.currencyRateToDollar
            self.priceLabel.text = SwiftExchanger.shared.currencySymbol + SwiftExchanger.shared.getFormattedNumber(number: price).description

        }
        if let percentChange24h = detailStruct.percentChange24h, let percentChange24h_float = Float(percentChange24h) {
            increaseLabel.text = percentChange24h_float < Float(0) ? percentChange24h.appending("%") : "+".appending(percentChange24h).appending("%")
            increaseLabel.textColor = percentChange24h_float < Float(0) ? GainsDownColor : GainsUpColor
            priceLabel.textColor = increaseLabel.textColor

        }

        guard var urlStr = detailStruct.icon, urlStr.count > 0 else {
            self.coinImageView.image = UIImage.init(named: "placeholderIcon")
            return
        }
        urlStr = urlStr.replacingOccurrences(of: " ", with: "%20")
        coinImageView.sd_setImage(with: URL(string: urlStr), placeholderImage: UIImage.init(named: "placeholderIcon"), options: SDWebImageOptions.retryFailed, completed: nil)
        
        let long: UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(longPress(long:)))
        self.addGestureRecognizer(long)
    }
    
    @objc func longPress(long: UILongPressGestureRecognizer){
        if long.state == UIGestureRecognizerState.began {
            let cell :AllTableViewCell = long.view as! AllTableViewCell
            let text: String = allDataModel!.favoriteStatus == 1 ? SWLocalizedString(key: "cancel_favorite") : SWLocalizedString(key: "add_favorite")
            self.becomeFirstResponder()
            let item = UIMenuItem.init(title: text, action: #selector(longButtonAction))
            let menu : UIMenuController = UIMenuController.shared
            menu.menuItems = [item]
            menu.setTargetRect(cell.frame, in: cell.superview!)
            menu.setMenuVisible(true, animated: true)
            
            let eventName = allDataModel!.favoriteStatus == 1 ? SWUEC_Show_AddFavorites_All_Page : SWUEC_Show_CancelFavorites_All_Page
            SPUserEventsManager.shared.addCount(forEvent: eventName)
        }
       
    }
    
    @objc func longButtonAction(){
        if delegate_favor != nil && indexPath_favor != nil {
            delegate_favor?.allDataFavoritesButtonAction(indexPath: indexPath_favor!)
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(longButtonAction) {
            return true
        }
        return false
    }

}
