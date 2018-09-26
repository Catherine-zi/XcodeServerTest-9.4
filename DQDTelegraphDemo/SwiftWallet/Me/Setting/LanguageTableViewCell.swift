//
//  LanguageTableViewCell.swift
//  DQDTelegraphDemo
//
//  Created by AVAZU on 2018/6/28.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class LanguageTableViewCell: UITableViewCell {

    @IBOutlet weak public var titleBtn: UIButton!
    @IBOutlet weak public var stateBtn: UIButton!
    @IBOutlet weak var separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func reuseIdentifier() -> String {
        return "LanguageTableViewCell"
    }
}
