//
//  SelectMnemonicCell.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/4.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

protocol TagManageCellDelegate: class {
    func tagCellDidTappedDelete(cell: TagManageCell)
}

class TagManageCell: UICollectionViewCell {
    
    weak var tagCellDelegate: TagManageCellDelegate?
	
	private let titleSelectColor:UIColor = UIColor.white
	private let titleUnSelectColor:UIColor = UIColor.init(hexColor: "282828")
	private let bvSelectColor:UIColor = UIColor.init(red: 30, green: 89, blue: 245)
	private let bvUnSelectColor:UIColor = UIColor.white
	@IBOutlet weak var backView: SWCornerRadiusView!
	@IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
	var isSelectedCell:Bool = false {
		didSet {
			backView.backgroundColor = isSelectedCell ? bvSelectColor : bvUnSelectColor
			titleL.textColor = isSelectedCell ? titleSelectColor : titleUnSelectColor
		}
	}
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		self.contentView.backgroundColor = superview?.backgroundColor
	}
    
    @IBAction func deleteTapped(_ sender: Any) {
        self.tagCellDelegate?.tagCellDidTappedDelete(cell: self)
    }
}
