//
//  FavoritesTableViewCell.swift
//  SwiftWallet
//
//  Created by Selin on 2018/4/9.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {//

    var longPressActionBlock :(()->())?
    @IBOutlet weak var coinIconImageView: UIImageView!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var pairLabel: UILabel!

    @IBOutlet weak var exchangeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var pairPriceLabel: UILabel!
    
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var constraint_priceLabel_Y: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    
    func reuseIdentifier() -> String {
        return "FavoritesTableViewCell"
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func fillDataWithDetailStruct(model: MarketsFavoritesDetailStruct, indexPath: IndexPath) {
        backgroundColor = Int(indexPath.row%2) == 1 ? UIColor.init(hexColor: "F8F8F8") : UIColor.white
        
        coinNameLabel.text = model.symbol
        let pairStrs = model.pair?.components(separatedBy: "/")
        if pairStrs?.count == 2 {
            pairLabel.text = String.init(format: "/%@", (pairStrs?.last)!)
            if let pairPrice = model.pairRightPrice, let pairPrice_float =  Float(pairPrice) {
                if pairPrice_float > 0, let pairPrice_Decimal = Decimal(string: pairPrice) {
//                    let pairPrice_fomat = SwiftExchanger.shared.getFormattedCurrencyString(amount: pairPrice_Decimal, inDollar: true, short: false)
                    let pairPrice_fomat = SwiftExchanger.shared.getShortedFormattedNumberString(number: pairPrice_Decimal)
                    pairPriceLabel.text = String.init(format: "=%@ %@", pairPrice_fomat, (pairStrs?.last)!)
                    constraint_priceLabel_Y.constant = 13
                }
            }
        } else {
            pairLabel.text = ""
            pairPriceLabel.text = ""
            constraint_priceLabel_Y.constant = 22

        }
        
        exchangeLabel.text = model.exchange?.count == 0 ? SWLocalizedString(key: "average") :  model.exchange
        if model.priceUSD != nil {
            if let priceStr = model.priceUSD,
                let price = Decimal(string: priceStr) {
                priceLabel.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: price, inDollar: true, short: false)
            } else {
                priceLabel.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: Decimal(), inDollar: true, short: false)
            }
        }
       
        if let percentChange24h = model.percentChange24h, let percentChange24h_float = Float(percentChange24h) {
            self.changeLabel.text = percentChange24h_float < Float(0) ? percentChange24h.appending("%") : "+".appending(percentChange24h).appending("%")
            self.changeLabel.backgroundColor  = percentChange24h_float < Float(0) ? GainsDownColor : GainsUpColor
        }
        
		
		if  let symbol = model.symbol,let image = UIImage.init(named: symbol) {
			coinIconImageView.image = image
		} else {
			
			guard var urlStr = model.icon, urlStr.count > 0 else {
				self.coinIconImageView.image = UIImage.init(named: "placeholderIcon")
				return
			}
			urlStr = urlStr.replacingOccurrences(of: " ", with: "%20")
			guard let url = URL.init(string: urlStr) else {
				coinIconImageView.image = UIImage.init(named: "placeholderIcon")
				return
			}
			coinIconImageView.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholderIcon"), options: SDWebImageOptions.retryFailed, completed: nil)
		}
        
        let long: UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(longPress(long:)))
        self.addGestureRecognizer(long)
    }
    
    @objc private func longPress(long: UILongPressGestureRecognizer){

        if longPressActionBlock != nil {
            longPressActionBlock!()
        }
    }

}

