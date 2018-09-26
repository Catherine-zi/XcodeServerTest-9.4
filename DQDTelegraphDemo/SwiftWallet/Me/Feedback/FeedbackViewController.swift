//
//  FeedbackViewController.swift
//  SwiftWallet
//
//  Created by Selin on 2018/5/22.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import PKHUD

class FeedbackViewController: UIViewController,UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var sendBtn: UIButton!

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        self.navTitleLabel.text = SWLocalizedString(key: "feedback")
        self.addressLabel.text = SWLocalizedString(key: "your_email_address")
        self.contentLabel.text = SWLocalizedString(key: "content")
        self.sendBtn.setTitle(SWLocalizedString(key: "feedback_send"), for: .normal)
        self.emailTextField.placeholder = SWLocalizedString(key: "input_your_email")
        self.contentTextView.text = SWLocalizedString(key: "input_your_probilem_or_advice")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonClick(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_Feedback_Page)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func sendButtonClick(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Send_Feedback_Page)

        let emailAddress = self.emailTextField.text
        if emailAddress?.count == 0 || emailAddress!.contains("@") ==  false || emailAddress?.contains(".") == false  {
            self.noticeOnlyText(SWLocalizedString(key: "Email Error."))
            return
        }
        
        let text = self.contentTextView.text
        if text?.count == 0 || text == SWLocalizedString(key: "input_your_probilem_or_advice") {
            self.noticeOnlyText(SWLocalizedString(key: "The feedback cannot be empty."))
            return
        }
        
        self.networkRequest(email: emailAddress!, content: text!)
        
    }
    
    func networkRequest(email: String, content: String) {
        LoginAPIProvider.request(LoginAPI.feedback(email, content)) { [weak self]result  in
            if case let .success(response) = result {
                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(SimpleStruct.self, from: decryptedData)
                
                self?.noticeOnlyText(SWLocalizedString(key: "thank_you_for_your_feedback"))
                if json?.code == 0 {
                    print("反馈成功")
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.noticeOnlyText(String(describing: json?.msg))
                }
            } else {
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
            }
        }
    }
    private func judgeSubmitableFrom(textField: UIView?, length: Int) {
        let emailAddress = self.emailTextField.text
        if emailAddress?.count == 0 || emailAddress!.contains("@") ==  false || emailAddress?.contains(".") == false  {
//            HUD.flash(.label(SWLocalizedString(key: "Email Error.")), delay: 1.0)
			
			self.sendBtn.backgroundColor = UIColor.init(hexColor: "DCDCDC")
			self.sendBtn.isEnabled = false
            return
        }
        
        let text = self.contentTextView.text
        if text?.count == 0 || text == SWLocalizedString(key: "input_your_probilem_or_advice") {
//            HUD.flash(.label(SWLocalizedString(key: "The feedback cannot be empty.")), delay: 1.0)
			self.sendBtn.backgroundColor = UIColor.init(hexColor: "DCDCDC")
			self.sendBtn.isEnabled = false
            return
        }
        self.sendBtn.backgroundColor = UIColor.init(hexColor: "1E59F5")
        self.sendBtn.isEnabled = true
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == SWLocalizedString(key: "input_your_probilem_or_advice") {
            textView.text = ""
        }
        textView.textColor = UIColor.black
        return true
    }
	
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let length = (textField.text?.count)! - range.length + string.count
        judgeSubmitableFrom(textField: textField, length: length)
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let length = (textView.text?.count)! - range.length + text.count
        judgeSubmitableFrom(textField: textView, length: length)
        return true
    }
	func textViewDidChange(_ textView: UITextView) {
		judgeSubmitableFrom(textField: textView, length: 0)
	}
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.emailTextField.resignFirstResponder()
        self.contentTextView.resignFirstResponder()
        
        if self.contentTextView.text == "" {
            self.contentTextView.text = SWLocalizedString(key: "input_your_probilem_or_advice")
            self.contentTextView.textColor = UIColor.init(hexColor: "BBBBBB")
        }
    }
}
