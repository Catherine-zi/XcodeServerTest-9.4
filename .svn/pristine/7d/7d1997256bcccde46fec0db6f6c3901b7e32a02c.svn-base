//
//  GainsSwitchTableViewCell.swift
//  SwiftWallet
//
//  Created by Selin on 2018/6/26.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class GainsSwitchTableViewCell: UITableViewCell {

   
    public let titleLbl:UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.init(hexColor: "333333")
        lb.font = UIFont.systemFont(ofSize: 15)
        return lb
    }()
    
    let gainsSwitch:UISwitch       = UISwitch()
    
//    let gainsBtn:UIButton       = {
//
//        let btn = UIButton.init(type: UIButtonType.custom)
//        btn.frame = CGRect.init(x: 0, y: 0, width: 50, height: 30)
//        btn.backgroundColor = UIColor.red
////        btn.tintColor = UIColor.blue
////        btn.onTintColor = UIColor.blue
//
//        btn.isSelected = UserDefaults.standard.bool(forKey: GainsColorUISwitchStateKey)
//        btn.addTarget(self, action: #selector(switchValueChanged(sender:)), for: UIControlEvents.touchUpInside)
//        return btn
//    }()
    private let backView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        gainsSwitch.tintColor = UIColor.init(hexColor: "F2F2F2")
        gainsSwitch.onTintColor = mainColor
        
        gainsSwitch.isOn = UserDefaults.standard.bool(forKey: GainsColorUISwitchStateKey)
        gainsSwitch.addTarget(self, action: #selector(switchValueChanged(sender:)), for: UIControlEvents.valueChanged)
        
        backView.backgroundColor = UIColor.white
        backView.layer.cornerRadius = 5
        backView.layer.masksToBounds = true
        self.contentView.addSubview(backView)
        backView.addSubview(titleLbl)
        backView.addSubview(gainsSwitch)
        
        backView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
        self.contentView.isUserInteractionEnabled = true
        titleLbl.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.leading.equalTo(self).offset(20)
        }
        gainsSwitch.snp.makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(30)
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).offset(-20)
        }
        
    }
    @objc func switchValueChanged(sender: UISwitch) {
//        var switchState:Bool = UserDefaults.standard.bool(forKey: GainsColorUISwitchStateKey)
//        switchState = !switchState
        
        UserDefaults.standard.set(sender.isOn, forKey: GainsColorUISwitchStateKey)
        TelegramUserInfo.shareInstance.settingColorFlag = sender.isOn
        
        NotificationCenter.post(customeNotification: SWNotificationName.gainsColor)

    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        
        self.backgroundColor = self.superview?.backgroundColor
        self.contentView.backgroundColor = self.backgroundColor
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
