//
//  ExchangeHeaderView.swift
//  DQDTelegraphDemo
//
//  Created by AVAZU on 2018/8/7.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class ExchangeHeaderView: UIView {
    
    typealias ExchangeHeaderButtonActionBlock = ((Int, String) -> ())
    var buttonSelectedBlock:ExchangeHeaderButtonActionBlock?
//    private var lastSelectedIndex: Int?
    var itemTitles:[String]? {
        didSet {
            button1.setTitle(itemTitles?.first, for: .normal)
            button1.setTitle(itemTitles?.first, for: .selected)
            
            button2.setTitle(itemTitles?[1], for: .normal)
            button2.setTitle(itemTitles?[1], for: .selected)
            
            button3.setTitle(itemTitles?.last, for: .normal)
            button3.setTitle(itemTitles?.last, for: .selected)
            
            button1.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            button2.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
            button3.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        }
    }
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!

    private var sortKey: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
    func setDefaultSelectedItem(btnTag: Int) {
        switch btnTag {
        case 0:
            button1.isSelected = true
            button1.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)

           break
        case 1:
            button2.isSelected = true
            button2.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)

            break
        case 2:
            button3.isSelected = true
            button3.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)

            break
        default:
            break
        }
    }
    @IBAction func button1Action(_ sender: UIButton) {
        switch sender.isSelected {
        case false:
            sender.isSelected = true
            sender.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)
            button2.isSelected = false
            button3.isSelected = false
            MarketsCoinPairsSortParamSelectedKey = MarketsCoinPairsSortParamKey.vo_desc.rawValue
            //排序
            break
        case true:
            // !排序
            if MarketsCoinPairsSortParamSelectedKey == MarketsCoinPairsSortParamKey.vo_desc.rawValue {
                sender.setImage(#imageLiteral(resourceName: "markets_all_sorting_up"), for: .selected)
                MarketsCoinPairsSortParamSelectedKey = MarketsCoinPairsSortParamKey.vo_asc.rawValue
            } else {
                sender.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)
                MarketsCoinPairsSortParamSelectedKey = MarketsCoinPairsSortParamKey.vo_desc.rawValue
            }
            break

        }

        if buttonSelectedBlock != nil {
            buttonSelectedBlock?(sender.tag,MarketsCoinPairsSortParamSelectedKey)
        }
    }
    
    @IBAction func button2Action(_ sender: UIButton) {
        switch sender.isSelected {
        case false:
            sender.isSelected = true
            sender.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)
            button1.isSelected = false
            button3.isSelected = false
            MarketsCoinPairsSortParamSelectedKey = MarketsCoinPairsSortParamKey.price_desc.rawValue

            //排序
            break
        case true:
            // !排序
            if MarketsCoinPairsSortParamSelectedKey == MarketsCoinPairsSortParamKey.price_desc.rawValue {
                sender.setImage(#imageLiteral(resourceName: "markets_all_sorting_up"), for: .selected)
                MarketsCoinPairsSortParamSelectedKey = MarketsCoinPairsSortParamKey.price_asc.rawValue
            } else {
                sender.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)
                MarketsCoinPairsSortParamSelectedKey = MarketsCoinPairsSortParamKey.price_desc.rawValue
            }
            break
        }

        if buttonSelectedBlock != nil {
            buttonSelectedBlock?(sender.tag,MarketsCoinPairsSortParamSelectedKey)
        }
    }
    
    @IBAction func button3Action(_ sender: UIButton) {
        switch sender.isSelected {
        case false:
            sender.isSelected = true
            sender.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)
            button2.isSelected = false
            button1.isSelected = false
            MarketsCoinPairsSortParamSelectedKey = MarketsCoinPairsSortParamKey.ch_desc.rawValue

            //排序
            break
        case true:
            // !排序
            if MarketsCoinPairsSortParamSelectedKey == MarketsCoinPairsSortParamKey.ch_desc.rawValue {
                sender.setImage(#imageLiteral(resourceName: "markets_all_sorting_up"), for: .selected)
                MarketsCoinPairsSortParamSelectedKey = MarketsCoinPairsSortParamKey.ch_asc.rawValue
            } else {
                sender.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)
                MarketsCoinPairsSortParamSelectedKey = MarketsCoinPairsSortParamKey.ch_desc.rawValue

            }
            break
        }

        if buttonSelectedBlock != nil {
            buttonSelectedBlock?(sender.tag,MarketsCoinPairsSortParamSelectedKey)
        }
    }
    
    func setButtonState(sortKey: MarketsCoinPairsSortParamKey) {
        switch sortKey {
        case .vo_asc, .vo_desc:
            button1.isSelected = true
            button2.isSelected = false
            button3.isSelected = false
            if sortKey == .vo_desc {
                button1.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)
            } else {
                button1.setImage(#imageLiteral(resourceName: "markets_all_sorting_up"), for: .selected)
            }
            
            break
        case .price_asc, .price_desc:
            button1.isSelected = false
            button2.isSelected = true
            button3.isSelected = false
            if sortKey == .price_desc {
                button2.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)
            } else {
                button2.setImage(#imageLiteral(resourceName: "markets_all_sorting_up"), for: .selected)
            }
            
            break
        case .ch_asc, .ch_desc:
            button1.isSelected = false
            button2.isSelected = false
            button3.isSelected = true
            if sortKey == .ch_desc {
                button3.setImage(#imageLiteral(resourceName: "markets_all_sorting_down"), for: .selected)
            } else {
                button3.setImage(#imageLiteral(resourceName: "markets_all_sorting_up"), for: .selected)
            }
            
            break
        }
    }
}
