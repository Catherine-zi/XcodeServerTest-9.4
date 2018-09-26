//
//  NotificationTableViewCell.swift
//  SwiftWallet
//
//  Created by Selin on 2018/5/23.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setContent(model: SwiftNotificationManager.NotificationModel) {
        
        self.titleLabel.text = SWLocalizedString(key: "push_title")
        if let isIn = model.isIn,
            let value = model.value
        {
            let str = isIn ? SWLocalizedString(key: "push_content_received") : SWLocalizedString(key: "push_content_sent")
            self.contentLabel.text = String.init(format: str, value)
        } else {
            self.contentLabel.text = ""
        }
        
        if let intervalStr = model.timestamp,
            let interval = TimeInterval(intervalStr)
        {
            let date = Date(timeIntervalSince1970: interval)
            let dateformatter = DateFormatter()
            dateformatter.locale = NSLocale(localeIdentifier: TelegramUserInfo.shareInstance.currentLanguage) as Locale?
            dateformatter.dateFormat = SWLocalizedString(key: "date_formatter")
            let dateStr = dateformatter.string(from: date)
            self.timeLabel.text = dateStr
        } else {
            self.timeLabel.text = ""
        }
    }
    
}
