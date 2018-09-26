//
//  AlertListViewController.swift
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/9/3.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class AlertListViewController: BaseNavViewController,UITableViewDelegate,UITableViewDataSource {
	
	private var mainTab:UITableView!
	private let noDataView = UIView()
	private var dataArr:[AlertDetailStruct] = []
	
	private var offset:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_MyAlert_page)

		setupViews()
		
		mainTab.mj_header = SwiftDiyHeader(refreshingBlock: {[weak self] in
			self?.loadData(offset: 0)
		})
		mainTab.mj_header.lastUpdatedTimeKey = "AlertListViewController"
		mainTab.mj_footer = MJRefreshAutoFooter.init(refreshingBlock: {[weak self] in
			if let offset = self?.dataArr.count {
				self?.loadData(offset: offset)
			}
		})

        mainTab.mj_header.beginRefreshing()
		
		
		NotificationCenter.default.addObserver(self, selector: #selector(getNotification), name: NSNotification.Name.init("PriceAlertArrive"), object: nil)
    }

	@objc func getNotification() {
		mainTab.mj_header.beginRefreshing()
	}
	private func loadData(offset:Int) {
		AlertAPIProvider.request(AlertAPI.alert_set_list(limit: 20, offset: offset)) { [weak self](result) in
			guard let strongSelf = self else {
				return
			}
			
			if case let .success(response) = result {
				
				let decryptedData = Data.init(decryptionResponseData: response.data)
				let json = try? JSONDecoder().decode(AlertListStruct.self, from: decryptedData)
				
				DispatchQueue.main.async(execute: {
					
					strongSelf.mainTab.mj_header.endRefreshing()
					strongSelf.mainTab.mj_footer.endRefreshing()
					if json?.code != 0 {
						strongSelf.noticeOnlyText(SWLocalizedString(key: "network_error"))
						return
					}
					if offset > 0 {//isloadMore
						if json?.data?.count == 0{
							strongSelf.mainTab.mj_footer.state = .noMoreData
							return
						}
						if let newDataArrs = json?.data {
							strongSelf.dataArr = strongSelf.dataArr + newDataArrs
							strongSelf.mainTab.reloadData()
						}
						
					}else {
						if json?.data?.count == 0{
							strongSelf.showNoDataView()
							return
						}
						//
						strongSelf.dataArr = json?.data ?? []
						strongSelf.mainTab.mj_footer.state = MJRefreshState.idle
						strongSelf.mainTab.reloadData()
					
					}
				})
				
				
			}else {
				strongSelf.noticeOnlyText(SWLocalizedString(key: "network_error"))
			}
		}
	}
	
	private func showNoDataView (){
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Empty_MyAlert_page)
		self.mainTab.isHidden = true
		self.noDataView.isHidden = false
	}
	private func setupViews() {
		
		contentView.backgroundColor = UIColor.init(hexColor: "F2F2F2")
		navTitle.text = SWLocalizedString(key: "my_alert_title")
		
		//add list btn
		let alertListBtn = UIButton()
		alertListBtn.setBackgroundImage(#imageLiteral(resourceName: "iconalertlist"), for: UIControlState.normal)
		alertListBtn.addTarget(self, action: #selector(clickAlertList), for: UIControlEvents.touchUpInside)
		navView.addSubview(alertListBtn)
		
		alertListBtn.snp.makeConstraints { (make) in
			make.centerY.equalTo(navView)
			make.right.equalTo(navView).offset(-15)
		}
		
		//tab
		mainTab = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.plain)
		contentView.addSubview(mainTab)
		mainTab.snp.makeConstraints { (make) in
			make.edges.equalTo(contentView)
		}
		mainTab.backgroundColor = contentView.backgroundColor
		mainTab.delegate = self
		mainTab.dataSource = self
		mainTab.separatorStyle = .none
		mainTab.register(AlertListTableViewCell.classForCoder(), forCellReuseIdentifier: "AlertListTableViewCell")
		
		//noDataView
		noDataView.backgroundColor = contentView.backgroundColor
		noDataView.isHidden = true
		contentView.addSubview(noDataView)
		noDataView.snp.makeConstraints { (make) in
			make.edges.equalTo(contentView)
		}
		let noRecordImageV = UIImageView(image: #imageLiteral(resourceName: "imagenorecord"))
		noDataView.addSubview(noRecordImageV)
		
		let noRecordLB = UILabel()
		noRecordLB.text = SWLocalizedString(key: "no_price_alert")
		noRecordLB.textColor = UIColor.init(hexColor: "999999")
		noRecordLB.font = UIFont.systemFont(ofSize: 12)
		
		noDataView.addSubview(noRecordLB)
		noDataView.addSubview(noRecordImageV)
		
		noRecordImageV.snp.makeConstraints { (make) in
			make.centerX.equalTo(noDataView)
			make.top.equalTo(noDataView).offset(220)
		}
		noRecordLB.snp.makeConstraints { (make) in
			make.centerX.equalTo(noRecordImageV)
			make.top.equalTo(noRecordImageV.snp.bottom).offset(12)
		}
	}
	@objc func clickAlertList() {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Click_History_MyAlert_Page)
		let alertVC = AlertHistoryViewController()
		self.navigationController?.pushViewController(alertVC, animated: true)
	}
	

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	func numberOfSections(in tableView: UITableView) -> Int {
        return dataArr.count

	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "AlertListTableViewCell") as! AlertListTableViewCell
		if indexPath.section < dataArr.count {
			let model = dataArr[indexPath.section]
			cell.model = model
			cell.longPressActionBlock = { [weak self] in

                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_DeleteAndEdit_Popup_MyAlert_page)
				let actionSheetVC : UIAlertController = UIAlertController.init()
				let deleteAction : UIAlertAction = UIAlertAction.init(title: SWLocalizedString(key: "delete_alert"), style: UIAlertActionStyle.destructive, handler: { [weak self] (action) in
					//MARK: delete action
                    SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Delete_MyAlert_Page)
					// code...
					guard let idStr = model.id,let id = Int(idStr) else {
						return
					}
					AlertAPIProvider.request(AlertAPI.alert_delete(id: id), completion: { [weak self](result) in
						
						guard let strongSelf = self else {
							return
						}
						
						if case let .success(response) = result {
							let decryptedData = Data.init(decryptionResponseData: response.data)
							let json = try? JSONDecoder().decode(AlertDeleteSuccessStruct.self, from: decryptedData)
							
							DispatchQueue.main.async(execute: {
								
								if json?.code == 0 && indexPath.section < strongSelf.dataArr.count{
									strongSelf.dataArr.remove(at: indexPath.section)
                                    if strongSelf.dataArr.count == 0 {
                                        strongSelf.noDataView.isHidden = false
                                    }
									strongSelf.mainTab.reloadData()
								}
							})
							
						}else {
							strongSelf.noticeOnlyText(SWLocalizedString(key: "network_error"))
						}
					})
				})
				let cancelAction: UIAlertAction = UIAlertAction.init(title: SWLocalizedString(key: "log_out_bitPub_dialog_cancel"), style: .cancel, handler: nil)
				let editAction: UIAlertAction = UIAlertAction.init(title: SWLocalizedString(key: "tag_management_edit"), style: UIAlertActionStyle.default, handler: { [weak self](action) in
                    SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Edit_MyAlert_Page)
					let vc = ExchangeAddAlertViewController()
					vc.exchangeName = model.exchange ?? ""
					vc.pairName = model.pair ?? ""
					vc.alertData = model
					vc.completeBlock = {self?.loadData(offset: 0)}
					
					self?.navigationController?.pushViewController(vc, animated: true)
				})
				actionSheetVC.addAction(deleteAction)
				actionSheetVC.addAction(editAction)
				actionSheetVC.addAction(cancelAction)
				self?.present(actionSheetVC, animated: true, completion: nil)
			}
		}
		cell.selectionStyle = .none
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.section < dataArr.count {
			let model = dataArr[indexPath.section]
			
			let vc = ExchangeAddAlertViewController()
			vc.exchangeName = model.exchange ?? ""
			vc.pairName = model.pair ?? ""
			vc.alertData = model
			vc.completeBlock = {self.loadData(offset: 0)}
			
			self.navigationController?.pushViewController(vc, animated: true)
		}
		
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 15
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerV = UIView()
		headerV.backgroundColor = contentView.backgroundColor
		headerV.frame = CGRect(x: 0, y: 0, width: SWScreen_width, height: 15)
		return UIView()
	}
    
    override func back() {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_MyAlert_page)
        super.back()
    }
    
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

struct AlertDeleteSuccessStruct:Decodable {
	var code:Int?
	var msg:String?
}
