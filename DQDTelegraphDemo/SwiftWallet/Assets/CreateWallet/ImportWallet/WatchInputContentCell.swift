//
//  InputContentCell.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/29.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class WatchInputContentCell: UITableViewCell {

	@IBOutlet weak var textView: SWPlaceholderTextView!
	@IBOutlet weak var cornerRadiusView: SWCornerRadiusView!
	override func awakeFromNib() {
        super.awakeFromNib()
		
		self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		self.contentView.backgroundColor = superview?.backgroundColor
	}
}
