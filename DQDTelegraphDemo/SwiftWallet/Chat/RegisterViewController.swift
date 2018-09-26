//
//  RegisterViewController.swift
//  SwiftWallet
//
//  Created by Selin on 2018/5/3.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!

    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var countryIDBtn: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navTitleLabel.text = SWLocalizedString(key: "my_account")
        self.tipsLabel.text = SWLocalizedString(key: "my_login_tips1")
//        self.phoneNumberLabel.text = SWLocalizedString(key: "")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func backBtnClick(_ sender: UIButton) {
        self.hidesBottomBarWhenPushed = false
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func countryIDBtnClick(_ sender: UIButton) {
        
    }
    @IBAction func nextButtonClick(_ sender: UIButton) {
        let confirmVC = TelegramConfirmViewController()
        confirmVC.phoneNumber = self.phoneNumberTextField.text! as NSString
        self.navigationController?.pushViewController(confirmVC, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let phoneNumberCount: Int = (textField.text?.count)!
        if phoneNumberCount < 10 {
            self.nextButton.isEnabled = false
            return true
        } else if  phoneNumberCount == 10 {
            self.nextButton.isEnabled = true
            return true
        } else {
            return false
        }

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.phoneNumberTextField.resignFirstResponder()
    }
}
