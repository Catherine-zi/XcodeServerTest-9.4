//
//  AlertDeletePopView.swift
//  DQDTelegraphDemo
//
//  Created by AVAZU on 2018/9/5.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class AlertDeletePopView: UIView {

    var ConirmDeleteAlertBlock: (() -> ())?
    var CancelDeleteAlertBlock: (() -> ())?
    
    @IBOutlet weak var tipsLabel: UILabel!

    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var confirmButton: UIButton!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        tipsLabel.text = SWLocalizedString(key: "delete_all_alert_history_tips")
        cancelButton.setTitle(SWLocalizedString(key: "log_out_bitPub_dialog_cancel"), for: .normal)
        confirmButton.setTitle(SWLocalizedString(key: "log_out_bitPub_dialog_confirm"), for: .normal)
    }
    @IBAction func closeBtnAction(_ sender: UIButton) {
        removeFromSuperview()
    }
    @IBAction func cancelBtnAction(_ sender: UIButton) {
        if CancelDeleteAlertBlock != nil {
            CancelDeleteAlertBlock!()
        }
        removeFromSuperview()
    }
    @IBAction func confirmBtnAction(_ sender: UIButton) {
        if ConirmDeleteAlertBlock != nil {
            ConirmDeleteAlertBlock!()
        }
        removeFromSuperview()
    }
}
