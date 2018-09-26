//
//  SelectCoinTypeViewController.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/30.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class SelectCoinTypeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
	var mainTab:UITableView?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpViews()
    }
	var selectTypeClosure:((Int) -> ())?
	private func setUpViews(){
		
		self.view.backgroundColor = UIColor.white
		
		self.addNavView()
		let tab:UITableView = UITableView.init(frame: CGRect.init(x: 0, y: SWStatusBarH+SWNavBarHeight, width: SWScreen_width, height: SWScreen_height - (SWStatusBarH+SWNavBarHeight)), style: UITableViewStyle.plain)
		tab.delegate = self
		tab.dataSource = self
		
		tab.register(SelectCoinTypeCell.classForCoder(), forCellReuseIdentifier: "SelectCoinTypeCell")
		tab.separatorColor = UIColor.init(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
		tab.separatorInset = UIEdgeInsets.zero
//		tab.backgroundColor = UIColor.init(hexColor: "F2F2F2")
		tab.tableFooterView = UIView()
		self.view.addSubview(tab)
		
		mainTab = tab
	}
	
	private func addNavView(){
		let navView:UIView = UIView.init(frame: CGRect.init(x: 0, y: SWStatusBarH, width: SWScreen_width, height: SWNavBarHeight))
		self.view.addSubview(navView)
		
		let backBtn:UIButton = UIButton.init()
		backBtn.addTarget(self, action: #selector(back), for: UIControlEvents.touchUpInside)
		backBtn.setImage(UIImage.init(named: "addAssets_back"), for: UIControlState.normal)
		
		
		
		navView.addSubview(backBtn)
		
		backBtn.snp.makeConstraints { (make) in
			make.left.equalTo(navView).offset(16)
			make.centerY.equalTo(navView)
			make.height.width.equalTo(44)
		}
		
	}

	@objc func back(){
		self.navigationController?.popViewController(animated: true)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell:SelectCoinTypeCell = tableView.dequeueReusableCell(withIdentifier: "SelectCoinTypeCell") as! SelectCoinTypeCell
		cell.contentView.backgroundColor = UIColor.init(red: 242, green: 242, blue: 242)
		cell.coinName.text = indexPath.row == 0 ? "BTC" : "ETH"
		cell.headV.image = indexPath.row == 0 ? #imageLiteral(resourceName: "BTC") : #imageLiteral(resourceName: "ETH")
		
		return cell
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 80
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if selectTypeClosure != nil {
			selectTypeClosure!(indexPath.row)
		}
		self.navigationController?.popViewController(animated: true)
	}
}

class SelectCoinTypeCell:UITableViewCell {
	
	let headV:UIImageView = UIImageView()
	let coinName:UILabel = UILabel()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		coinName.textColor = UIColor.init(hexColor: "333333")
		coinName.font = UIFont.boldSystemFont(ofSize: 16)
		
		self.contentView.addSubview(headV)
		self.contentView.addSubview(coinName)
		
		headV.snp.makeConstraints { (make) in
			make.centerY.equalTo(self.contentView)
			make.leading.equalTo(self.contentView).offset(16)
			make.width.height.equalTo(52)
		}
		coinName.snp.makeConstraints { (make) in
			make.centerY.equalTo(headV)
			make.leading.equalTo(headV.snp.trailing).offset(9)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

