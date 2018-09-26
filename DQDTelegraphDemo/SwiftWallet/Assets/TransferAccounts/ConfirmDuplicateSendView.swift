//
//  BackUpVerifyPwdView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/24.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class ConfirmDuplicateSendView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var warnAgainLbl: UILabel!
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("ConfirmDuplicateSendView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth] 
        contentView.addGestureRecognizer(UITapGestureRecognizer.init())
        
        self.warnAgainLbl.text = SWLocalizedString(key: "duplicate_send_hint") + " " + SWLocalizedString(key: "continue_hint")
        self.cancelBtn.setTitle(SWLocalizedString(key: "log_out_bitPub_dialog_cancel"), for: .normal)
        self.confirmBtn.setTitle(SWLocalizedString(key: "wallet_confirm"), for: .normal)
    }

	typealias CancelbBlock = () -> ()
    typealias ExcuteBlock = () -> ()
	var cancelBlock:CancelbBlock?
    var excuteBlock:ExcuteBlock?
	
    @IBAction func confirmTapped(_ sender: Any) {
        if self.excuteBlock != nil {
            self.excuteBlock!()
        }
    }
    
    func setWarnAgainText(text:String) {
        self.warnAgainLbl.text = text
    }
	
	@IBAction func clickCancel(_ sender: UIButton) {
		if cancelBlock != nil {
			cancelBlock!()
		}
		
	}
}
