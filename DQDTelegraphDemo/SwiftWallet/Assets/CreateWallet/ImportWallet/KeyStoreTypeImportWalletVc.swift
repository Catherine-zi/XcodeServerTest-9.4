//
//  KeyStoreTypeImportWalletVc.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/30.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class KeyStoreTypeImportWalletVc: UIViewController,UITableViewDataSource,UITableViewDelegate {
	
	private lazy var tab:UITableView = {
		
		var tabFrame:CGRect = CGRect.init(x: 0, y: 0, width: SWScreen_width, height: (SWScreen_height - SafeAreaTopHeight - 44 - 50 - ((SWScreen_height == 812.0) ? iPhoneXBottomHeight : 0)))
		let tab:UITableView = UITableView.init(frame: tabFrame, style: UITableViewStyle.plain)
		
		tab.delegate = self
		tab.dataSource = self
		
		tab.register(UINib.init(nibName: "SingleCoinTypeCell", bundle: nil), forCellReuseIdentifier: "SingleCoinTypeCell")
		tab.register(UINib.init(nibName: "SetKeystorePasswordCell", bundle: nil), forCellReuseIdentifier: "SetKeystorePasswordCell")
		tab.register(UINib.init(nibName: "InputWalletNameCell", bundle: nil), forCellReuseIdentifier: "InputWalletNameCell")
		tab.register(UINib.init(nibName: "SetWalletPassword", bundle: nil), forCellReuseIdentifier: "SetWalletPassword")
		tab.register(UINib.init(nibName: "AgreeServicePolicyCell", bundle: nil), forCellReuseIdentifier: "AgreeServicePolicyCell")
		tab.estimatedRowHeight = 100
		
		tab.separatorStyle = .none
		tab.backgroundColor = UIColor.init(hexColor: "F2F2F2")
		
		let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tap(gesture:)))
		tab.addGestureRecognizer(tap)
		
		return tab
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Import_Keystore_Page)
		
		setUpViews()
		
	}
	
	private func setUpViews() {
		
		view.addSubview(tab)
		
		let startBtn:UIButton = UIButton.init(frame: CGRect.init(x: 0, y: tab.frame.size.height, width: SWScreen_width, height: 50))
		startBtn.addTarget(self, action: #selector(startImport), for: UIControlEvents.touchUpInside)
		startBtn.backgroundColor = UIColor.init(red: 35, green: 89, blue: 245)
		startBtn.setTitle(SWLocalizedString(key: "walle_start_import"), for: UIControlState.normal)
		startBtn.setTitleColor(UIColor.white, for: .normal)
		startBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
		view.addSubview(startBtn)
	}
	
	@objc private func tap(gesture:UITapGestureRecognizer){
		UIApplication.shared.keyWindow?.endEditing(false)
	}
	@objc private func startImport(){
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Start_Import_Keystore)
		
	}
	
	// UITableViewDelegate
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return 5
	}
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 16
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headV:UIView = UIView()
		headV.backgroundColor = tab.backgroundColor
		return headV
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch indexPath.section {
		case 0:
			let cell:SingleCoinTypeCell = tableView.dequeueReusableCell(withIdentifier: "SingleCoinTypeCell") as! SingleCoinTypeCell
			return cell
		case 1:
			let cell:SetKeystorePasswordCell = tableView.dequeueReusableCell(withIdentifier: "SetKeystorePasswordCell") as! SetKeystorePasswordCell
			return cell
		case 2:
			let cell:InputWalletNameCell = tableView.dequeueReusableCell(withIdentifier: "InputWalletNameCell") as! InputWalletNameCell
			return cell
		case 3:
			let cell:SetWalletPassword = tableView.dequeueReusableCell(withIdentifier: "SetWalletPassword") as! SetWalletPassword
			return cell
		case 4:
			let cell:AgreeServicePolicyCell = tableView.dequeueReusableCell(withIdentifier: "AgreeServicePolicyCell") as! AgreeServicePolicyCell
			return cell
		default:
			return UITableViewCell()
		}
	}
	
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		UIApplication.shared.keyWindow?.endEditing(false)
	}
}

