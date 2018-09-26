//
//  NotificationViewController.swift
//  SwiftWallet
//
//  Created by Selin on 2018/5/22.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataMsgLabel: UILabel!

    var notifications: [SwiftNotificationManager.NotificationModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_Notification_Page)
        self.navTitleLabel.text = SWLocalizedString(key: "notification_title")
        self.noDataMsgLabel.text = SWLocalizedString(key: "no_notify")
        self.noDataView.isHidden = true
        self.notifications = SwiftNotificationManager.shared.notificationArray
        tableView.register(UINib.init(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationTableViewCell")
        self.configureContent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func configureContent() {
        print("\(self.notifications.count)")
        if (self.notifications.count > 0) {
            SPUserEventsManager.shared.trackEventAction(SWUEC_Show_NotificationList, eventPrame: "1")
            self.noDataView.isHidden = true
            self.tableView.isHidden = false
        } else {
            SPUserEventsManager.shared.trackEventAction(SWUEC_Show_NotificationList, eventPrame: "2")

            self.noDataView.isHidden = false
            self.tableView.isHidden = true
        }
    }
    @IBAction func backButtonClick(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_Notification_Page)
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:NotificationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        cell.setContent(model: self.notifications[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.notifications[indexPath.row]
        let transactionVC = TransactionListViewController()
        transactionVC.filteAddress = model.address
        transactionVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(transactionVC, animated: true)
    }
    
    deinit {
        if SwiftNotificationManager.shared.notificationCount != 0 {
            SwiftNotificationManager.shared.notificationCount = 0
            NotificationCenter.post(customeNotification: SWNotificationName.changeNotification)
        }
    }
    
}
