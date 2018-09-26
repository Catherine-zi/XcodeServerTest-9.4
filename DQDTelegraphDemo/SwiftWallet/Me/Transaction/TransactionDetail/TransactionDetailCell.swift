//
//  WalletDetailCell.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/7.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit


class TransactionDetailCell: UITableViewCell {
    
    public enum TransactionDetailCellPositionType: String {
        case TransactionDetailCellPositionAlone
        case TransactionDetailCellPositionTop
        case TransactionDetailCellPositionBottom
        case TransactionDetailCellPositionMiddle
    }
    
    lazy var backView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        self.contentView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(0)
            make.left.equalTo(15)
            make.right.equalTo(-15)
        }
        return view
    }()
    
    var upperBackView:UIView?
    var downBackView:UIView?
    var titleLbl:UILabel?
    var accLbl:UILabel?
    var idLbl:UILabel?
    var accImgView:UIImageView?
    var separator:UIView?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = UIColor.init(hexColor: "f2f2f2")
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.backgroundColor = UIColor.clear
        
//        self.backView = UIView()
//        self.backView!.backgroundColor = UIColor.white
//        self.backView!.clipsToBounds = true
//        self.backView!.layer.cornerRadius = 5
//        self.contentView.addSubview(self.backView!)
//        self.backView!.snp.makeConstraints { (make) in
//            make.top.bottom.equalTo(0)
//            make.left.equalTo(15)
//            make.right.equalTo(-15)
//        }
        
        self.upperBackView = self.makeWhiteBack()
        self.contentView.addSubview(self.upperBackView!)
        self.upperBackView!.snp.makeConstraints { (make) in
            make.height.equalTo(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(0)
        }
        
        self.downBackView = self.makeWhiteBack()
        self.contentView.addSubview(self.downBackView!)
        self.downBackView!.snp.makeConstraints { (make) in
            make.height.equalTo(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(0)
        }
        
        self.titleLbl = UILabel()
        self.titleLbl!.font = UIFont.systemFont(ofSize: 16)
        self.titleLbl!.textColor = UIColor.init(hexColor: "999999")
        self.backView.addSubview(self.titleLbl!)
        self.titleLbl!.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
            make.top.equalTo(0)
            make.height.equalTo(50)
            make.bottom.equalTo(0)
        }
        self.titleLbl!.setContentCompressionResistancePriority(UILayoutPriority.required, for: UILayoutConstraintAxis.horizontal)
        
        self.accLbl = UILabel()
        self.accLbl!.font = UIFont.systemFont(ofSize: 16)
        self.accLbl!.textColor = UIColor.black
        self.accLbl!.textAlignment = .right
        self.backView.addSubview(self.accLbl!)
        self.accLbl!.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
        }
        
        self.accImgView = UIImageView()
        self.accImgView!.image = UIImage.init(named: "me_rightArrow")
        self.backView.addSubview(self.accImgView!)
        self.accImgView!.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
            make.width.equalTo(8.5)
            make.height.equalTo(13.5)
        }
        
        self.idLbl = UILabel()
        self.idLbl!.font = UIFont.systemFont(ofSize: 16)
        self.idLbl!.textColor = UIColor.init(hexColor: "356AF6")
        self.idLbl!.textAlignment = .right
        self.backView.addSubview(self.idLbl!)
        self.idLbl!.isHidden = true
        self.idLbl!.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.accImgView!.snp.left).offset(-20)
            make.left.greaterThanOrEqualTo(self.titleLbl!.snp.right).offset(20)
        }
        
        self.separator = UIView()
        self.separator!.backgroundColor = UIColor.init(white: 242.0 / 255, alpha: 1)
        self.backView.addSubview(self.separator!)
        self.separator!.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.bottom.equalTo(0)
            make.left.equalTo(15)
            make.right.equalTo(-15)
        }
    }
    
    func configureContent(data:[String: String]) {
        if data["title"] == nil || data["accType"] == nil {
            return
        }
        self.titleLbl?.text = data["title"]!
        if data["accType"]! == "text" {
            self.accLbl?.isHidden = false
            self.accImgView?.isHidden = true
            self.idLbl?.isHidden = true
        } else if data["accType"]! == "id" {
            self.accLbl?.isHidden = true
            self.accImgView?.isHidden = false
            self.idLbl?.isHidden = false
        } else {
            self.accLbl?.isHidden = true
            self.accImgView?.isHidden = false
            self.idLbl?.isHidden = true
        }
        self.accLbl?.text = data["accText"] ?? ""
        self.idLbl?.text = data["accText"] ?? ""
    }
    
    func configureType(type:TransactionDetailCellPositionType) {
        switch type {
        case .TransactionDetailCellPositionAlone:
            self.upperBackView?.isHidden = true
            self.downBackView?.isHidden = true
            self.separator?.isHidden = true
        case .TransactionDetailCellPositionTop:
            self.upperBackView?.isHidden = true
            self.downBackView?.isHidden = false
            self.separator?.isHidden = false
        case .TransactionDetailCellPositionBottom:
            self.upperBackView?.isHidden = false
            self.downBackView?.isHidden = true
            self.separator?.isHidden = true
        case .TransactionDetailCellPositionMiddle:
            self.upperBackView?.isHidden = false
            self.downBackView?.isHidden = false
            self.separator?.isHidden = false
        }
    }
    
    private func makeWhiteBack() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }

}
