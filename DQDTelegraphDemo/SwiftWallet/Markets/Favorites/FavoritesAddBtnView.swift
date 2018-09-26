//
//  FavoritesAddBtnView.swift
//  SwiftWallet
//
//  Created by Selin on 2018/4/9.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

protocol AddButtonClickDelegate {
    func addButtonClicked(_ sender: UIButton)
}

class FavoritesAddBtnView: UIView {
    
    
    @IBOutlet weak var addCoinsLabel: UILabel!
    
    override func awakeFromNib() {
        self.addCoinsLabel.text = SWLocalizedString(key: "add_favorite")
        
    }


    @IBAction func addButtonClick(_ sender: UIButton) {
//        let vc = TagManageViewController()
        let vc:MarketsSearchViewController = MarketsSearchViewController()
        self.viewController().navigationController?.pushViewController(vc, animated: true)
    }
}
