//
//  AssetsDetailHeaderCardView.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/26.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class AssetsDetailHeaderCardView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var balanceLbl: UILabel!
    @IBOutlet weak var legalBalanceLbl: UILabel!
    @IBOutlet weak var circleView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("AssetsDetailHeaderCardView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
       
    }
    
    func setContent(model: AssetsTokensModel) {
//        UIView.animate(withDuration: 0.3, animations: {
            self.iconImgView.alpha = 0
            self.balanceLbl.alpha = 0
            self.nameLbl.alpha = 0
            self.legalBalanceLbl.alpha = 0
            self.circleView.alpha = 0
//        }) { (_) in

            self.nameLbl.text = model.symbol
            var balanceStr = "0.0"
            if model.balance != nil {
                if model.balance! < 10000000000 {
                    balanceStr = String(model.balance!.description.prefix(10))
                } else {
                    balanceStr = model.balance!.description
                }
            }
            self.balanceLbl.text = balanceStr
        self.legalBalanceLbl.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: (model.balanceInLegal ?? Decimal()), inDollar: false, short: false)//SwiftExchanger.shared.currencySymbol
                //+ (SwiftExchanger.shared.convertLegalDecimal(currency: model.balanceInLegal) ?? "0.0")
            UIView.animate(withDuration: 0.3, animations: {
                self.iconImgView.alpha = 1
                self.balanceLbl.alpha = 1
                self.nameLbl.alpha = 1
                self.legalBalanceLbl.alpha = 1
                self.circleView.alpha = 1
            }, completion: { (_) in
                
            })

		if  let symbol = model.symbol,let image = UIImage.init(named: symbol) {
			self.iconImgView.image = image
		}else {
			guard var urlStr = model.iconUrl, (urlStr.count) > 0 else {
				self.iconImgView.image = UIImage.init(named: "placeholderIcon")
				return
			}
		
			urlStr = urlStr.replacingOccurrences(of: " ", with: "%20")
			self.iconImgView.sd_setImage(with: URL(string: urlStr), placeholderImage: UIImage.init(named: "placeholderIcon"), options: SDWebImageOptions.retryFailed, completed: nil)
		}
    }

}
