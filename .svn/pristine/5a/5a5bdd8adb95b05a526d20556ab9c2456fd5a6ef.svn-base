//
//  WebViewController.swift
//  SwiftWallet
//
//  Created by Selin on 2018/6/5.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var titleView: UIView!
    public var urlStr: String?
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

        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleView.snp.bottom)
            make.left.right.bottom.equalTo(0)
        }
        webView.addSubview(self.progressView)
		
		if let urlStr = self.urlStr, let url = NSURL(string: urlStr){
			let requst = URLRequest(url: url as URL)
			webView.load(requst as URLRequest)
		}
      
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.progressView.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.progressView.progress = 0.0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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


