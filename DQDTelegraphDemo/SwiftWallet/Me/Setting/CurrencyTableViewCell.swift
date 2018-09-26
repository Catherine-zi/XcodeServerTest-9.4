//
//  LanguageTableViewCell.swift
//  DQDTelegraphDemo
//
//  Created by AVAZU on 2018/6/28.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak public var titleBtn: UIButton!
    @IBOutlet weak public var stateBtn: UIButton!
    @IBOutlet weak var separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
//    public func loadCellLanguageAndState(_ language:String, state: Bool){
//        self.titleBtn.setTitle(language, for: .normal)
//        self.stateBtn.isSelected = state
//    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        self.titleBtn.isSelected = selected
//        self.stateBtn.isSelected = selected
        // Configure the view for the selected state
    }
    func reuseIdentifier() -> String {
        return "CurrencyTableViewCell"
    }
}
