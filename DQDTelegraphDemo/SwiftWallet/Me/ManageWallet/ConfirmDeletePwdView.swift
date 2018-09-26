//
//  BackUpVerifyPwdView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/24.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class ConfirmDeletePwdView: UIView {
    
    @IBOutlet var contentView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("ConfirmDeletePwdView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.addGestureRecognizer(UITapGestureRecognizer.init())
    }

	typealias CancelbBlock = () -> ()
	typealias ConfirmBlock = (String) -> Bool
    typealias ExcuteBlock = () -> ()
	var cancelBlock:CancelbBlock?
	var confirmBlock:ConfirmBlock?
    var excuteBlock:ExcuteBlock?
	@IBOutlet weak var pwdInput: UITextField!
	
    @IBAction func confirmTapped(_ sender: Any) {
        if (confirmBlock != nil){
            
            let result:Bool = confirmBlock!(pwdInput.text!)
            if result {
                self.errorTips.isHidden = true;
                if self.excuteBlock != nil {
                    self.excuteBlock!()
                }
            } else {
                self.errorTips.isHidden = false;
            }
        }
    }
	
	@IBOutlet weak var errorTips: UILabel!
	
	@IBAction func clickCancel(_ sender: UIButton) {
		if cancelBlock != nil {
			cancelBlock!()
		}
		
	}
}
