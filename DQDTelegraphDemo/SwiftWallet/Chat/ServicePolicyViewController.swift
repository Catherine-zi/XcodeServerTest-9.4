//
//  ServicePolicyViewController.swift
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/8/9.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit
import WebKit
class ServicePolicyViewController: UIViewController, WKNavigationDelegate {

	var urlStr: String?
	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var disagreeBtn: UIButton!
	@IBOutlet weak var agreeBtn: UIButton!
	@IBAction func clickDisAgree(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)
	}
	@IBAction func clickAgreeBtn(_ sender: UIButton) {
		
		
		UserDefaults.standard.set(true, forKey: "isAgreeServicePolicy")
		UserDefaults.standard.synchronize()
		
		let confirmVC = TelegramConfirmViewController()
		self.navigationController?.pushViewController(confirmVC, animated: true)
		SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_LogIn_ChatPage)
	}
	@IBAction func clickBack(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	lazy var webView: WKWebView = {
		let web = WKWebView()
		
		
		web.navigationDelegate = self
		
		return web
	}()
	
	// 进度条
	lazy var progressView:UIProgressView = {
		let progress = UIProgressView()
		progress.progressTintColor = UIColor.blue
		progress.trackTintColor = .clear
		progress.frame = CGRect(x:0,y:0,width:self.view.frame.size.width,height:2)
		return progress
	}()
	override func viewDidLoad() {
        super.viewDidLoad()

		self.contentView.addSubview(webView)
		webView.snp.makeConstraints { (make) in
			make.edges.equalTo(self.contentView)
		}
		webView.addSubview(self.progressView)
		
		if let urlStr = self.urlStr, let url = NSURL(string: urlStr){
			let requst = URLRequest(url: url as URL)
			webView.load(requst as URLRequest)
		}
		
		self.agreeBtn.isHidden = true
		self.disagreeBtn.isHidden = true
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.progressView.isHidden = false
		UIView.animate(withDuration: 1.0) {
			self.progressView.progress = 0.0
		}
	}
	// 页面开始加载时调用
	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
		/// 获取网页的progress
		UIView.animate(withDuration: 0.5) {
			self.progressView.progress = Float(self.webView.estimatedProgress)
		}
	}
	// 当内容开始返回时调用
	func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
		
	}
	// 页面加载完成之后调用
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
		/// 获取网页title
		//        self.title = self.webView.title
		
		UIView.animate(withDuration: 0.5) {
			self.progressView.progress = 1.0
			self.progressView.isHidden = true
		}
		
		self.agreeBtn.isHidden = false
		self.disagreeBtn.isHidden = false
	}
	// 页面加载失败时调用
	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){
		
		UIView.animate(withDuration: 0.5) {
			self.progressView.progress = 0.0
			self.progressView.isHidden = true
		}
		/// 弹出提示框点击确定返回
		let alertView = UIAlertController.init(title: "", message: "Load failed", preferredStyle: .alert)
		let okAction = UIAlertAction.init(title:"OK", style: .default) { okAction in
			_=self.navigationController?.popViewController(animated: true)
		}
		alertView.addAction(okAction)
		self.present(alertView, animated: true, completion: nil)
		
	}

}
