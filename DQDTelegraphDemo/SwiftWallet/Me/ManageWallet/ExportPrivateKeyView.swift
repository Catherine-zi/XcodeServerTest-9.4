//
//  BackUpVerifyPwdView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/24.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import PKHUD

class ExportPrivateKeyView: UIView {
    
    var key:String = "" {
        didSet {
            self.keyLbl.text = key
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var keyLbl: UILabel!
    @IBOutlet weak var copyBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        Bundle.main.loadNibNamed("ExportPrivateKeyView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.addGestureRecognizer(UITapGestureRecognizer.init())
        
        self.titleLabel.text = SWLocalizedString(key: "export_private_key")
        self.warningLabel.text = SWLocalizedString(key: "export_wallet_tip")
        self.copyBtn.setTitle(SWLocalizedString(key: "copy"), for: .normal)
    }
    
    @IBAction func copyTapped(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_CopyPrivateKey)
        UIPasteboard.general.string = self.keyLbl.text
        
        self.noticeOnlyText(SWLocalizedString(key: "copy_success"))

//        self.noticeOnlyText("Private key copied to pasteboard")
    }
    
}
