//
//  BaseNavViewController.swift
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/8/1.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class BaseNavViewController: UIViewController {

	let navView:UIView = UIView()
	let backBtn:UIButton = UIButton()
	let navTitle:UILabel = UILabel()
	let contentView:UIView = UIView()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		contentView.backgroundColor = UIColor.white
		
		setUpView()
		
    }
	private func setUpView(){
	
		view.addSubview(navView)
		view.addSubview(contentView)
		
		navView.snp.makeConstraints { (make) in
			make.left.equalTo(view)
			make.right.equalTo(view)
			make.height.equalTo(44)
			make.top.equalTo(view).offset(SWStatusBarH)
		}
		contentView.snp.makeConstraints { (make) in
			make.top.equalTo(navView.snp.bottom)
			make.left.equalTo(view)
			make.right.equalTo(view)
			make.bottom.equalTo(view)
		}
		
		backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
		backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
		backBtn.setImage(#imageLiteral(resourceName: "addAssets_back"), for: UIControlState.normal)
		
		navTitle.font = UIFont.boldSystemFont(ofSize: 15)
		navTitle.textColor = UIColor.init(hexColor: "333333")
		
		navView.backgroundColor = UIColor.white
		
		navView.addSubview(backBtn)
		navView.addSubview(navTitle)
		
		backBtn.snp.makeConstraints { (make) in
			make.centerY.equalTo(navView)
			make.left.equalTo(navView).offset(15)
			make.height.width.equalTo(40)
		}
		navTitle.snp.makeConstraints { (make) in
			make.centerY.equalTo(navView)
			make.centerX.equalTo(navView)
		}
	}

	@objc func back() {
		self.navigationController?.popViewController(animated: true)
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
}
