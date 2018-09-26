//
//  AllHeaderView.swift
//  SwiftWallet
//
//  Created by Selin on 2018/4/9.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class PairHeaderView: UIView {

    @IBOutlet weak var volSortingBtn: SortButton!
    @IBOutlet weak var changeSortingBtn: SortButton!
    @IBOutlet weak var priceSortingBtn: SortButton!
    
    var sortBtnArray: [SortButton] = []
    
    override func awakeFromNib() {
        
        self.volSortingBtn.setTitle(SWLocalizedString(key: "ex_vol"), for: .normal)
        self.changeSortingBtn.setTitle(SWLocalizedString(key: "change"), for: .normal)
        self.priceSortingBtn.setTitle(SWLocalizedString(key: "price"), for: .normal)
        self.updateInset(btn: self.volSortingBtn)
        self.updateInset(btn: self.changeSortingBtn)
        self.updateInset(btn: self.priceSortingBtn)
        
        self.sortBtnArray = [self.volSortingBtn, self.changeSortingBtn, self.priceSortingBtn]
    }
    
    private func updateInset(btn: UIButton) {
        if let size = btn.titleLabel?.sizeThatFits(CGSize.zero) {
            btn.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -15, bottom: 0, right: 15)
            btn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: size.width, bottom: 0, right: -size.width)
        }
    }
}

class SortButton: UIButton {
    var isAsc = false {
        didSet {
            if isAsc {
                self.setImage(#imageLiteral(resourceName: "markets_all_sorting_up"), for: .selected)
            } else {
                self.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)
            }
        }
    }
}
