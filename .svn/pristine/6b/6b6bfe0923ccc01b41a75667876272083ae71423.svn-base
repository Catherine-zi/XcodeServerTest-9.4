//
//  AssetsMoreBtnPopView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/23.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class AssetsMoreBtnPopView: UIView,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var mainTab: UITableView!
	
	private let dataSource:Array = [[SWLocalizedString(key: "assets_watch_text"),"iconwatchw"],[SWLocalizedString(key: "assets_import_text"),"iconimportw"],[SWLocalizedString(key: "assets_create_text"),"iconcreatew"],[SWLocalizedString(key: "assets_menu_scan"),"iconscanw"]]
	var clickPopViewBlock:((Int) -> ())?
	
	override func awakeFromNib() {
		super.awakeFromNib()

		self.layer.cornerRadius = 6
		self.layer.masksToBounds = true
		mainTab.delegate = self
		mainTab.dataSource = self
//		mainTab.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//		mainTab.separatorColor = UIColor.init(white: 0.0, alpha: 0.1)
		mainTab.backgroundColor = UIColor.clear
		self.backgroundColor = UIColor.clear
		mainTab.register(AssetsMoreBtnPopCell.classForCoder(), forCellReuseIdentifier: "AssetsMoreBtnPopCell")
		mainTab.bounces = false
        mainTab.separatorStyle = .none
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell:AssetsMoreBtnPopCell = tableView.dequeueReusableCell(withIdentifier: "AssetsMoreBtnPopCell") as! AssetsMoreBtnPopCell
		
		let imageName:String 		  = dataSource[indexPath.row][1]
		let name:String	     		  = dataSource[indexPath.row][0]
		cell.imageV.image			  = UIImage.init(named: imageName)
		cell.nameL.text				  = name
        
        if indexPath.row == 3 {
            cell.separator.isHidden = true
        }
		
		return cell
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 4
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if clickPopViewBlock != nil {
			clickPopViewBlock?(indexPath.row)
		}
		self.superview?.removeFromSuperview()
		print("indexPath.row = \(indexPath.row)")
	}
}

class AssetsMoreBtnPopCell: UITableViewCell {
	
	let imageV:UIImageView = UIImageView.init()
	let nameL:UILabel = UILabel.init()
    let separator = UIView()
    private let backColor:UIColor = UIColor.init(white: 40/255.0, alpha: 0.9)
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		nameL.textColor = UIColor.white
		nameL.font = UIFont.systemFont(ofSize: 12)
		
		self.contentView.addSubview(imageV)
		self.contentView.addSubview(nameL)
		imageV.snp.makeConstraints { (make) in
			make.centerY.equalTo(self.contentView)
			make.left.equalTo(self.contentView).offset(16)
		}
		nameL.snp.makeConstraints { (make) in
			make.centerY.equalTo(imageV)
			make.left.equalTo(imageV.snp.right).offset(16)
		}
        
        separator.backgroundColor = UIColor.white
        separator.alpha = 0.9
        self.contentView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(0)
            make.height.equalTo(1)
        }
		
		self.contentView.backgroundColor = backColor
		self.backgroundColor = self.contentView.backgroundColor
		self.selectionStyle = .none
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
