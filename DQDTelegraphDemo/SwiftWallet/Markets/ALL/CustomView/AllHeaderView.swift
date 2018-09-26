//
//  AllHeaderView.swift
//  SwiftWallet
//
//  Created by Selin on 2018/4/9.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class AllHeaderView: UIView {

    @IBOutlet weak var nameBtn: UIButton!   
    @IBOutlet weak var volSortingBtn: UIButton!
    @IBOutlet weak var changeSortingBtn: UIButton!

    var SelectedItemBlock:((Int, String) -> ())?
//    private var lastSelectedIndex: Int?
    
    override func awakeFromNib() {
        
        self.nameBtn.setTitle(SWLocalizedString(key: "name"), for: .normal)
        self.volSortingBtn.setTitle(SWLocalizedString(key: "vol"), for: .normal)
        self.changeSortingBtn.setTitle(SWLocalizedString(key: "change"), for: .normal)

        
//        self.nameBtn.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        self.volSortingBtn.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        self.changeSortingBtn.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft

    }
    @IBAction func button1Action(_ sender: UIButton) {
        switch sender.isSelected {
        case false:
            sender.isSelected = true
            volSortingBtn.isSelected = false
            changeSortingBtn.isSelected = false
            //排序
            break
        case true:
            break
        }
//        lastSelectedIndex = sender.tag
        
        if SelectedItemBlock != nil {
            SelectedItemBlock?(sender.tag,MarketsAllTagSortSelectedKey)
        }
    }
    
    @IBAction func button2Action(_ sender: UIButton) {
        switch sender.isSelected {
        case false:
            sender.isSelected = true
            sender.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)
            nameBtn.isSelected = false
            changeSortingBtn.isSelected = false
            MarketsAllTagSortSelectedKey = MarketsAllTagSortParamKey.vo_desc.rawValue
            //排序
            break
        case true:
            // !排序
            if MarketsAllTagSortSelectedKey == MarketsAllTagSortParamKey.vo_desc.rawValue {
                sender.setImage(#imageLiteral(resourceName: "markets_all_sorting_up"), for: .selected)
                MarketsAllTagSortSelectedKey = MarketsAllTagSortParamKey.vo_asc.rawValue
            } else {
                sender.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)
                MarketsAllTagSortSelectedKey = MarketsAllTagSortParamKey.vo_desc.rawValue
            }
            
            break
        }
        
        if SelectedItemBlock != nil {
            SelectedItemBlock?(sender.tag,MarketsAllTagSortSelectedKey)
        }
    }
    
    @IBAction func button3Action(_ sender: UIButton) {
        switch sender.isSelected {
        case false:
            sender.isSelected = true
            sender.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)
            nameBtn.isSelected = false
            volSortingBtn.isSelected = false
            MarketsAllTagSortSelectedKey = MarketsAllTagSortParamKey.ch_desc.rawValue

            //排序
            break
        case true:
            // !排序
            if  MarketsAllTagSortSelectedKey == MarketsAllTagSortParamKey.ch_desc.rawValue {
                sender.setImage(#imageLiteral(resourceName: "markets_all_sorting_up"), for: .selected)
                MarketsAllTagSortSelectedKey = MarketsAllTagSortParamKey.ch_asc.rawValue

            } else {
                sender.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)
                MarketsAllTagSortSelectedKey = MarketsAllTagSortParamKey.ch_desc.rawValue

            }
            break
           
        }
        
        if SelectedItemBlock != nil {
            SelectedItemBlock?(sender.tag,MarketsAllTagSortSelectedKey)
        }
    }
    
    func setSortingButton() {
        if let key = MarketsAllTagSortParamKey(rawValue: MarketsAllTagSortSelectedKey) {
            switch key {
            case .cap_asc, .cap_desc, .price_asc, .price_desc:
                self.nameBtn.isSelected = true
                self.volSortingBtn.isSelected = false
                self.changeSortingBtn.isSelected = false
                if key == .cap_asc || key == .price_asc {
                    self.nameBtn.setImage(#imageLiteral(resourceName: "markets_all_coin_sorting_up"), for: .selected)
                } else {
                    self.nameBtn.setImage(#imageLiteral(resourceName: "markets_all_coin_sorting_down"), for: .selected)
                }
            case .vo_asc, .vo_desc:
                self.nameBtn.isSelected = false
                self.volSortingBtn.isSelected = true
                self.changeSortingBtn.isSelected = false
                if key == .vo_asc {
                    self.volSortingBtn.setImage(#imageLiteral(resourceName: "markets_all_sorting_up"), for: .selected)
                } else {
                    self.volSortingBtn.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)
                }
            case .ch_asc, .ch_desc:
                self.nameBtn.isSelected = false
                self.volSortingBtn.isSelected = false
                self.changeSortingBtn.isSelected = true
                if key == .ch_asc {
                    self.changeSortingBtn.setImage(#imageLiteral(resourceName: "markets_all_sorting_up"), for: .selected)
                } else {
                    self.changeSortingBtn.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)
                }
            }
        }
    }
}
