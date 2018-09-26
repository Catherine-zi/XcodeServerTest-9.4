//
//  MarketPairCell.swift
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/8/7.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

protocol FavoritesButtonActionDelegate {
    func favoritesButtonAction(indexPath: IndexPath)
}

class MarketPairCell: UITableViewCell {
    
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var pairLbl: UILabel!
    @IBOutlet weak var volLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var pricePairLbl: UILabel!
    @IBOutlet weak var rateLbl: UILabel!
    
    private var coinPairModel: MarketsCoinPairDataModel?
    private var indexPath_favor: IndexPath?

     var delegate_favor: FavoritesButtonActionDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setContent(model: MarketsCoinPairDataModel, indexPath: IndexPath) {
        
        coinPairModel = model
        indexPath_favor = indexPath
        backgroundColor = Int(indexPath.row%2) == 1 ? UIColor.init(hexColor: "F8F8F8") : UIColor.white

        var pairSymbol = ""
        if let symbol = model.symbol,
            let pair = model.pair {
            pairSymbol = pair.replacingOccurrences(of: symbol + "/", with: "")
        }
        
        self.titleLbl.text = model.symbol
        self.pairLbl.text = "/" + pairSymbol
        if let volStr = model.volume_24h,
            let vol = Decimal(string: volStr) {
//            self.volLbl.text = SwiftExchanger.shared.getShortedFormattedNumberString(number: vol)
            self.volLbl.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: vol, inDollar: true, short: true)
        } else {
            self.volLbl.text = "--"
        }
        if let priceStr = model.price_usd,
            let price = Decimal(string: priceStr) {
            self.priceLbl.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: price, inDollar: true, short: false)
        } else {
            self.priceLbl.text = "--"
        }
        if let pricePairStr = model.pair_right_price,
            let price = Decimal(string: pricePairStr) {
            self.pricePairLbl.text = SwiftExchanger.shared.getFormattedNumber(number: price).description + pairSymbol
        } else {
            self.pricePairLbl.text = "--"
        }

        if let percentChange24h = model.price_change_usd_24h, let percentChange24h_float = Float(percentChange24h) {
            self.rateLbl.text = percentChange24h_float < Float(0) ? percentChange24h.appending("%") : "+".appending(percentChange24h).appending("%")
            
            self.rateLbl.backgroundColor  = percentChange24h_float < Float(0) ? GainsDownColor : GainsUpColor
        } else {
            self.rateLbl.text = "--"
        }
       
        guard var urlStr = model.icon, urlStr.count > 0 else {
            self.iconImgView.image = UIImage.init(named: "placeholderIcon")
            return
        }
        urlStr = urlStr.replacingOccurrences(of: " ", with: "%20")
        iconImgView.sd_setImage(with: URL(string: urlStr), placeholderImage: UIImage.init(named: "placeholderIcon"), options: SDWebImageOptions.retryFailed, completed: nil)
        
        let long: UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(longPress(long:)))
        self.addGestureRecognizer(long)
    }
    
    func fillDataWithMarketsCoinPairDataModel(model: MarketsCoinPairDataModel, indexPath: IndexPath) {
        coinPairModel = model
        indexPath_favor = indexPath
        backgroundColor = Int(indexPath.row%2) == 1 ? UIColor.init(hexColor: "F8F8F8") : UIColor.white

        var pairSymbol = ""
        if let symbol = model.symbol,
            let pair = model.pair {
            pairSymbol = pair.replacingOccurrences(of: symbol + "/", with: "")
        }

        self.titleLbl.text = model.exchange
        self.pairLbl.text = "/" + pairSymbol
        if let volStr = model.volume_24h,
            let vol = Decimal(string: volStr) {
            self.volLbl.text = SwiftExchanger.shared.getShortedFormattedNumberString(number: vol)
        } else {
            self.volLbl.text = "--"
        }
        if let priceStr = model.price_usd,
            let price = Decimal(string: priceStr) {
            self.priceLbl.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: price, inDollar: true, short: false)
        } else {
            self.priceLbl.text = "--"
        }
        if let pricePairStr = model.pair_right_price,
            let price = Decimal(string: pricePairStr) {
            self.pricePairLbl.text = SwiftExchanger.shared.getFormattedNumber(number: price).description + pairSymbol
        } else {
            self.pricePairLbl.text = "--"
        }
      
        if let percentChange24h = model.price_change_usd_24h, let percentChange24h_float = Float(percentChange24h) {
            self.rateLbl.text = percentChange24h_float < Float(0) ? percentChange24h.appending("%") : "+".appending(percentChange24h).appending("%")
            
            self.rateLbl.backgroundColor  = percentChange24h_float < Float(0) ? GainsDownColor : GainsUpColor
        } else {
            self.rateLbl.text = "--"
        }
        
        guard var urlStr = model.icon, urlStr.count > 0 else {
            self.iconImgView.image = UIImage.init(named: "placeholderIcon")
            return
        }
        urlStr = urlStr.replacingOccurrences(of: " ", with: "%20")
        iconImgView.sd_setImage(with: URL(string: urlStr), placeholderImage: UIImage.init(named: "placeholderIcon"), options: SDWebImageOptions.retryFailed, completed: nil)
        
        let long: UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(longPress(long:)))
        self.addGestureRecognizer(long)
    }
    
    @objc func longPress(long: UILongPressGestureRecognizer){
        if long.state == UIGestureRecognizerState.began {
            let cell :MarketPairCell = long.view as! MarketPairCell
            let text: String = coinPairModel!.favorite_status == 1 ? SWLocalizedString(key: "cancel_favorite") : SWLocalizedString(key: "add_favorite")
            self.becomeFirstResponder()
            let item = UIMenuItem.init(title: text, action: #selector(longButtonAction))
            let menu : UIMenuController = UIMenuController.shared
            menu.menuItems = [item]
            menu.setTargetRect(cell.frame, in: cell.superview!)
            
            menu.setMenuVisible(true, animated: true)
        }
        
    }
    
    @objc func longButtonAction(){
        if delegate_favor != nil && indexPath_favor != nil {
            delegate_favor?.favoritesButtonAction(indexPath: indexPath_favor!)
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
