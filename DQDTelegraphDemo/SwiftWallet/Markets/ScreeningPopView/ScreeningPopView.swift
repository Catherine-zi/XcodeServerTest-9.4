//
//  ScreeningPopView.swift
//  SwiftWallet
//
//  Created by Selin on 2018/4/12.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

let ScreeningPopViewNotification = NSNotification.Name(rawValue: "ScreeningPopViewNotification")

class ScreeningPopView: AllSortingDismissView {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var capUpBtn: UIButton!
    @IBOutlet weak var capDownBtn: UIButton!
    @IBOutlet weak var priceUpBtn: UIButton!
    @IBOutlet weak var priceDownBtn: UIButton!
    var ScreeningButtonActionBlock:((UIButton) -> ())?
    
   public var selectedKey:String?
    
    override func awakeFromNib() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeFromSuperview), name: SWNotificationName.dismissAllSortingView.notificationName, object: nil)
        
        self.capUpBtn.setTitle(SWLocalizedString(key: "market_cap_asc"), for: .normal)
        self.capDownBtn.setTitle(SWLocalizedString(key: "market_cap_des"), for: .normal)
        self.priceUpBtn.setTitle(SWLocalizedString(key: "price_asc"), for: .normal)
        self.priceDownBtn.setTitle(SWLocalizedString(key: "price_des"), for: .normal)

        self.setButtonSelected()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.exceptFrame = backView.frame
    }
    
    func setButtonSelected() {
        switch MarketsAllTagSortSelectedKey {
        case MarketsAllTagSortParamKey.cap_asc.rawValue:
            self.capUpBtn.isSelected = true
            self.capDownBtn.isSelected = false
            self.priceUpBtn.isSelected = false
            self.priceDownBtn.isSelected = false
            break
        case MarketsAllTagSortParamKey.cap_desc.rawValue:
            self.capDownBtn.isSelected = false
            self.capDownBtn.isSelected = true
            self.priceUpBtn.isSelected = false
            self.priceDownBtn.isSelected = false
            break
        case MarketsAllTagSortParamKey.price_asc.rawValue:
            self.priceUpBtn.isSelected = false
            self.capDownBtn.isSelected = false
            self.priceUpBtn.isSelected = true
            self.priceDownBtn.isSelected = false
            break
        case MarketsAllTagSortParamKey.price_desc.rawValue:
            self.priceDownBtn.isSelected = false
            self.capDownBtn.isSelected = false
            self.priceUpBtn.isSelected = false
            self.priceDownBtn.isSelected = true
            break
        default:
            break
        }
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        if ScreeningButtonActionBlock != nil {
            ScreeningButtonActionBlock!(sender)
        }
//        NotificationCenter.default.post(name: ScreeningPopViewNotification, object: sender)
        self.removeFromSuperview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeFromSuperview()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

