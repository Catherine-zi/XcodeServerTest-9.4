//
//  AlertHistoryTableViewCell.swift
//  DQDTelegraphDemo
//
//  Created by AVAZU on 2018/9/4.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class AlertHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeTitleLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    var longPressActionBlock:( ()->() )?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let long: UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(longPress(long:)))
        self.addGestureRecognizer(long)
    }
    
    @objc private func longPress(long: UILongPressGestureRecognizer){
        
        if longPressActionBlock != nil {
            longPressActionBlock!()
        }
    }
    
    func fillDataWithModel(model: AlertMsgHistoryDataModel) {
        msgLabel.text = model.message
        let timeStamp = model.create_time
        if timeStamp != nil && timeStamp?.count != 0 {
            let timeInterval:TimeInterval = TimeInterval(timeStamp!)!
            let date = Date(timeIntervalSince1970: timeInterval)
            let dformatter = DateFormatter()
            dformatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            timeTitleLabel.text = dformatter.string(from: date)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
