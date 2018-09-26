//
//  WalletDetailCell.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/7.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit


class WalletDetailCell: UITableViewCell {
    
    public enum WalletDetailCellPositionType: String {
        case WalletDetailCellPositionAlone
        case WalletDetailCellPositionTop
        case WalletDetailCellPositionBottom
        case WalletDetailCellPositionMiddle
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
    
    var accImgView:UIImageView?
    
    var separator:UIView?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
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
        self.titleLbl!.textColor = UIColor.darkGray
        self.backView.addSubview(self.titleLbl!)
        self.titleLbl!.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
        
        self.accImgView = UIImageView()
        self.accImgView!.contentMode = .scaleAspectFit
        self.accImgView!.image = UIImage.init(named: "me_rightArrow")
        self.backView.addSubview(self.accImgView!)
        self.accImgView!.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
            make.width.equalTo(17)
            make.height.equalTo(27)
        }
        
        self.accLbl = UILabel()
        self.accLbl!.font = UIFont.systemFont(ofSize: 16)
        self.accLbl!.textColor = UIColor.init(white: 138.0 / 255, alpha: 1)
        self.accLbl!.textAlignment = .right
        self.backView.addSubview(self.accLbl!)
        self.accLbl!.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.accImgView!.snp.left).offset(-8)
        }
        
        self.separator = UIView()
        self.separator!.backgroundColor = UIColor.init(white: 242.0 / 255, alpha: 1)
        self.backView.addSubview(self.separator!)
        self.separator!.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.equalTo(0)
            make.left.equalTo(15)
            make.right.equalTo(-15)
        }
    }
    
    func configureContent(data:[String: String]) {
        if self.titleLbl == nil || self.accLbl == nil || self.accImgView == nil {
            return
        }
        guard let title = data["title"],
        let type = data["accType"] else {
            return
        }
        self.titleLbl!.text = title
        if type == "text" {
            self.accLbl!.isHidden = false
            self.accImgView!.isHidden = true
            self.accImgView!.snp.updateConstraints { (make) in
                make.width.equalTo(0)
            }
            self.accLbl!.snp.updateConstraints { (make) in
                make.right.equalTo(self.accImgView!.snp.left).offset(0)
            }
        } else if type == "arrow" {
            self.accLbl!.isHidden = true
            self.accImgView!.isHidden = false
            self.accImgView!.snp.updateConstraints { (make) in
                make.width.equalTo(17)
            }
            self.accLbl!.snp.updateConstraints { (make) in
                make.right.equalTo(self.accImgView!.snp.left).offset(-8)
            }
        } else {
            self.accLbl!.isHidden = false
            self.accImgView!.isHidden = false
            self.accImgView!.snp.updateConstraints { (make) in
                make.width.equalTo(17)
            }
            self.accLbl!.snp.updateConstraints { (make) in
                make.right.equalTo(self.accImgView!.snp.left).offset(-8)
            }
        }
        self.accLbl!.text = data["accText"] ?? ""
    }
    
    func configureType(type:WalletDetailCellPositionType) {
        switch type {
        case .WalletDetailCellPositionAlone:
            self.upperBackView?.isHidden = true
            self.downBackView?.isHidden = true
            self.separator?.isHidden = true
        case .WalletDetailCellPositionTop:
            self.upperBackView?.isHidden = true
            self.downBackView?.isHidden = false
            self.separator?.isHidden = false
        case .WalletDetailCellPositionBottom:
            self.upperBackView?.isHidden = false
            self.downBackView?.isHidden = true
            self.separator?.isHidden = true
        case .WalletDetailCellPositionMiddle:
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
