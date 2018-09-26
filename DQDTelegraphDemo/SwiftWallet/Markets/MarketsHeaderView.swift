//
//  MarketsHeaderView.swift
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/8/22.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class MarketsHeaderView: UIView {

    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var coinBtn: UIButton!
    @IBOutlet weak var exchangeBtn: UIButton!
    @IBOutlet weak var refLeft: UIView!
    @IBOutlet weak var refRight: UIView!
    @IBOutlet weak var rollingBar: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpViews()
    }
    
    private func setUpViews() {
        self.favoriteBtn.setTitle(SWLocalizedString(key: "favorite"), for: .normal)
        self.favoriteBtn.setTitle(SWLocalizedString(key: "favorite"), for: .selected)
        self.coinBtn.setTitle(SWLocalizedString(key: "coins"), for: .normal)
        self.coinBtn.setTitle(SWLocalizedString(key: "coins"), for: .selected)
        self.exchangeBtn.setTitle(SWLocalizedString(key: "exchange"), for: .normal)
        self.exchangeBtn.setTitle(SWLocalizedString(key: "exchange"), for: .selected)
        
        self.rollingBar.frame = CGRect.init(x: -10, y: 0, width: 20, height: 3)
    }

}
