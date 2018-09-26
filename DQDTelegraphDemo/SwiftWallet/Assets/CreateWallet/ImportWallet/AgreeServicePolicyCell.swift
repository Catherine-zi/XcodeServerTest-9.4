//
//  AgreeServicePolicyCell.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/30.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class AgreeServicePolicyCell: UITableViewCell,UITextViewDelegate {

	@IBOutlet weak var serviceTextView: UITextView!
	
    override func awakeFromNib() {
		super.awakeFromNib()
		self.selectionStyle = .none
		
		self.serviceTextView.backgroundColor = UIColor.clear
		self.serviceTextView.delegate = self
		
		addTextViewContent()
		
	}
	
	func addTextViewContent() {
		
		let serviceStr:NSString = SWLocalizedString(key: "terms_of_service") as NSString
		let policyStr:NSString = SWLocalizedString(key: "privacy_policy") as NSString
		let tgString:NSString = String.init(format: SWLocalizedString(key: "wallet_agree"), serviceStr,policyStr) as NSString
		
//		let attrString:NSMutableAttributedString = NSMutableAttributedString.init(string: tgString as String)
		
		let serviceRange:NSRange = tgString.range(of: serviceStr as String)
		let policyRange:NSRange = tgString.range(of: policyStr as String)
		
	
		
		// 新增的文本内容（使用默认设置的字体样式）
		let attrs = [NSAttributedStringKey.font : self.serviceTextView.font!,
					 NSAttributedStringKey.foregroundColor : self.serviceTextView.textColor ?? UIColor.black]
		
		let appendString = NSMutableAttributedString(string: tgString as String, attributes:attrs)
		
		
		appendString.addAttribute(NSAttributedStringKey.link, value:"service", range:serviceRange)
		appendString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSNumber.init(integerLiteral: NSUnderlineStyle.styleSingle.rawValue), range: serviceRange)
		appendString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.init(hexColor: "1E59F5"), range: serviceRange)
		
		
		
		appendString.addAttribute(NSAttributedStringKey.link, value:"policy", range:policyRange)
		appendString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSNumber.init(integerLiteral: NSUnderlineStyle.styleSingle.rawValue), range: policyRange)
		appendString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.init(hexColor: "1E59F5"), range: policyRange)
		
	
		
		// 设置合并后的文本
		self.serviceTextView.attributedText = appendString
	}
	
	@IBOutlet weak var selectBtn: UIButton!
	@IBAction func selectBtn(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
		
	}
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
		print(URL.absoluteString)
		if (URL.scheme == "look") {
			
		}
		return true
	}
	@available(iOS 10.0, *)
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

		if URL.absoluteString == "service" {
            
            var urlStr:String
            
            if TelegramUserInfo.shareInstance.currentLanguage.caseInsensitiveCompare(CurrentLanguage.Chinese_Hans.rawValue).rawValue == 0 || TelegramUserInfo.shareInstance.currentLanguage.caseInsensitiveCompare(CurrentLanguage.Chinese_Hant.rawValue).rawValue == 0 {
                urlStr = ServiceAgreementCN
            } else {
                urlStr = ServiceAgreementEN
            }
			let webViewVC:WebViewController = WebViewController()
			webViewVC.urlStr = urlStr
			self.viewController().navigationController?.pushViewController(webViewVC, animated: true)
		}
		if URL.absoluteString == "policy" {
            var urlStr:String
            if TelegramUserInfo.shareInstance.currentLanguage.caseInsensitiveCompare(CurrentLanguage.Chinese_Hans.rawValue).rawValue == 0 || TelegramUserInfo.shareInstance.currentLanguage.caseInsensitiveCompare(CurrentLanguage.Chinese_Hant.rawValue).rawValue == 0 {
                urlStr = PrivacyAgreementCN
            } else {
                urlStr = PrivacyAgreementEN
            }
			let webViewVC:WebViewController = WebViewController()
			webViewVC.urlStr = urlStr
			self.viewController().navigationController?.pushViewController(webViewVC, animated: true)
		}
		return true
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
