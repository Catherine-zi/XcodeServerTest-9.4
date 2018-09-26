//
//  ChangePasswordViewController.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/8.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import PKHUD

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var currentPswLabel: UILabel!
    @IBOutlet weak var newPswLabel: UILabel!
    @IBOutlet weak var repeatPswLabel: UILabel!

    @IBOutlet weak var oriPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var currentView: UIView!
    @IBOutlet weak var currentErrorLbl: UILabel!
    @IBOutlet weak var newView: UIView!
    @IBOutlet weak var newErrorLbl: UILabel!
    
    var walletModel:SwiftWalletModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_ChangePassword_Page)
        setUpViews()
    }
    
    func setUpViews() {
        
        self.navTitleLabel.text = SWLocalizedString(key: "change_password")
        self.currentPswLabel.text = SWLocalizedString(key: "current_password")
        self.newPswLabel.text = SWLocalizedString(key: "new_password")
        self.repeatPswLabel.text = SWLocalizedString(key: "repeat_password")
        
        self.oriPasswordField.placeholder = SWLocalizedString(key: "please_enter_your_current_password")
        self.newPasswordField.placeholder = SWLocalizedString(key: "at_least_8_digits")
        self.repeatPasswordField.placeholder = SWLocalizedString(key: "repeat_your_password")
        
        self.currentErrorLbl.text = SWLocalizedString(key: "current_password_is_wrong")
        self.newErrorLbl.text = SWLocalizedString(key: "inconsistent_passwords_entered")

        self.submitBtn.setTitle(SWLocalizedString(key: "change_password"), for: .normal)
        
        self.oriPasswordField.delegate = self
        self.newPasswordField.delegate = self
        self.repeatPasswordField.delegate = self
        
        self.currentView.layer.borderColor = UIColor.white.cgColor
        self.newView.layer.borderColor = UIColor.white.cgColor
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.oriPasswordField {
            self.oriPasswordField.resignFirstResponder()
            self.newPasswordField.becomeFirstResponder()
        } else if textField == self.newPasswordField {
            self.newPasswordField.resignFirstResponder()
            self.repeatPasswordField.becomeFirstResponder()
        } else if textField == self.repeatPasswordField {
            self.repeatPasswordField.resignFirstResponder()
            if self.submitBtn.isEnabled {
                submitPassword()
            }
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text != nil {
            let length = textField.text!.count - range.length + string.count
            if length >= 8 {
                if judgeSubmitableFrom(field: textField) {
                    enableSubmitBtn(enable: true)
                    return true
                }
            }
        }
        enableSubmitBtn(enable: false)
        return true
    }
    
    func judgeSubmitableFrom(field: UITextField) -> Bool {
        var fieldArr:[UITextField] = [self.oriPasswordField, self.newPasswordField, self.repeatPasswordField]
        if let index = fieldArr.index(of: field) {
            fieldArr.remove(at: index)
        }
        var submitable = true
        for object in fieldArr {
            if object.text != nil {
                if object.text!.count < 8 {
                    submitable = false
                    break
                }
            } else {
                submitable = false
                break
            }
        }
        return submitable
    }
    
    func enableSubmitBtn(enable:Bool) {
        if enable {
            self.submitBtn.backgroundColor = UIColor.init(hexColor: "1E59F5")
            self.submitBtn.isEnabled = true
        } else {
            self.submitBtn.backgroundColor = UIColor.init(hexColor: "DCDCDC")
            self.submitBtn.isEnabled = false
        }
    }

    func submitPassword() {
        
        if self.walletModel == nil || self.walletModel!.password == nil {
            return
        }
        
        if self.newPasswordField.text != self.repeatPasswordField.text {
            self.newView.layer.borderColor = UIColor.init(hexColor: "F76D6F").cgColor
            self.currentView.layer.borderColor = UIColor.white.cgColor
            self.newErrorLbl.isHidden = false
            self.currentErrorLbl.isHidden = true
            return
        } else if self.oriPasswordField.text != SwiftWalletManager.shared.normalDecrypt(string: self.walletModel!.password!){
            self.currentView.layer.borderColor = UIColor.init(hexColor: "F76D6F").cgColor
            self.newView.layer.borderColor = UIColor.white.cgColor
            self.newErrorLbl.isHidden = true
            self.currentErrorLbl.isHidden = false
            return
        }
        self.currentView.layer.borderColor = UIColor.white.cgColor
        self.currentErrorLbl.isHidden = true
        self.newErrorLbl.isHidden = true
        if self.walletModel!.extendedPrivateKey == nil {
            self.noticeOnlyText(SWLocalizedString(key: "unknown_error"))
            return
        }
        let isSuccess = SwiftWalletManager.shared.modifyPassword(privateKeyHash: self.walletModel!.extendedPrivateKey!, password: self.newPasswordField.text!)
        if isSuccess {
            self.noticeOnlyText(SWLocalizedString(key: "change_password_success"))
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    

    @IBAction func submitTapped(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Confirm_ChangePassword)
        submitPassword()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_ChangePassword_Page)
        self.navigationController?.popViewController(animated: true)
    }
    
}
