//
//  BackUpVerifyPwdView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/24.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class ConfirmPwdView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var warnLbl: UILabel!
    @IBOutlet weak var warnAgainLbl: UILabel!
    @IBOutlet weak var pswErrorLabel: UILabel!
    
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
        Bundle.main.loadNibNamed("ConfirmPwdView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth] 
        contentView.addGestureRecognizer(UITapGestureRecognizer.init())
		
		contentView.layer.cornerRadius = 4
		contentView.layer.masksToBounds = true
		
        self.warnLbl.text = SWLocalizedString(key: "delete_wallet_tip_1")
        self.warnAgainLbl.text = SWLocalizedString(key: "delete_wallet_tip_2")
        self.pswErrorLabel.text = SWLocalizedString(key: "inconsistent_passwords_entered")
        self.cancelBtn.setTitle(SWLocalizedString(key: "log_out_bitPub_dialog_cancel"), for: .normal)
        self.confirmBtn.setTitle(SWLocalizedString(key: "wallet_confirm"), for: .normal)
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
    
    func setWarnText(text:String) {
        self.warnLbl.text = text
    }
    
    func setWarnAgainText(text:String) {
        self.warnAgainLbl.text = text
    }
	
	@IBOutlet weak var errorTips: UILabel!
	
	@IBAction func clickCancel(_ sender: UIButton) {
		if cancelBlock != nil {
			cancelBlock!()
		}
		
	}
}
