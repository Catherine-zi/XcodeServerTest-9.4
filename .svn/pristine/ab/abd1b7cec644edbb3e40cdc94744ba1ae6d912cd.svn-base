//
//  MeMutiTableViewCell.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/21.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class MeMutiTableViewCell: UITableViewCell,UITableViewDataSource,UITableViewDelegate {
	
	var dataArr:[MeCellModel]? = [] {
		didSet {
			tab.reloadData()
			
			backView.layer.cornerRadius = 5
			backView.layer.masksToBounds = true
		}
	}
	
	private let backView = UIView()
	private let tab = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.plain)
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		setUpViews()
	}
	
	private func setUpViews() {
		
		backView.backgroundColor = UIColor.white
		
		self.contentView.addSubview(backView)
		backView.snp.makeConstraints { (make) in
			make.edges.equalTo(self.contentView)
		}
		
		tab.delegate = self
		tab.dataSource = self
//		tab.bounces = false
		tab.separatorStyle = .none
		tab.register(MeTableViewCell.classForCoder(), forCellReuseIdentifier: "MeTableViewCell")
		
		backView.addSubview(tab)
		tab.snp.makeConstraints { (make) in
			make.edges.equalTo(backView)
		}
		tab.isScrollEnabled = false
	}
	
	override func willMove(toSuperview newSuperview: UIView?) {
		
		self.backgroundColor = self.superview?.backgroundColor
		self.contentView.backgroundColor = self.backgroundColor
		
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (dataArr?.count)!
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell:MeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MeTableViewCell") as! MeTableViewCell
		
		var dataA = dataArr![indexPath.row]
		dataA.sepIsHidden = indexPath.row == (dataArr?.count)! - 1 ? true : false
        dataA.notificationIsHidden = true
        if indexPath.row == 0 {
            if SwiftNotificationManager.shared.notificationCount > 0 {
                dataA.notificationIsHidden = false
                dataA.notificationText = String(SwiftNotificationManager.shared.notificationCount)
            }
        }
		
		cell.model = dataA
		
		cell.selectionStyle = .none
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 48
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.0
	}
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        switch indexPath.row {
        case 0:
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Notification)
            let vc:NotificationViewController = NotificationViewController()
            vc.hidesBottomBarWhenPushed = true
            self.viewController().navigationController?.pushViewController(vc, animated: true)
            break
        case 1:
//            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_RateUs)
//            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Asscore_Popup)
//
//            let rateUsView:RateUsView = Bundle.main.loadNibNamed("RateUsView", owner: self, options: nil)?.first as! RateUsView
//            rateUsView.frame = CGRect.init(x: 0, y: 0, width: SWScreen_width, height: SWScreen_height)
//            let keywindow = UIApplication.shared.keyWindow
//            UIApplication.shared.keyWindow?.backgroundColor = UIColor.black
//            UIApplication.shared.keyWindow?.makeKeyAndVisible()
//            UIApplication.shared.keyWindow?.isUserInteractionEnabled = true
//            keywindow?.addSubview(rateUsView)
//            rateUsView.confirmRateBlock = {[weak self] () in
//                let fbVC: FeedbackViewController =  FeedbackViewController()
//                fbVC.hidesBottomBarWhenPushed = true
//                self?.viewController().navigationController?.pushViewController(fbVC, animated: true)
//            }
//            break
//        case 2:
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Feedback)
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_Feedback_Page)

            let vc:FeedbackViewController = FeedbackViewController()
            vc.hidesBottomBarWhenPushed = true
            self.viewController().navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
    }
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
