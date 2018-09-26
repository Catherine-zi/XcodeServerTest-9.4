//
//  MarketsSearchTableViewCell.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/10.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
protocol MarketsSearchCollectionProtocol {
	func didSelectItem(symbol: String)
}
class MarketsSearchTableViewCell: UITableViewCell,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate {
	
	var delegate:MarketsSearchCollectionProtocol?
	var dataArr:Array<String> = Array(){
		didSet {
			
			mainCollectionView.reloadData()
			mainCollectionView.snp.updateConstraints({ (make) in
				make.height.equalTo(mainCollectionView.collectionViewLayout.collectionViewContentSize.height)
			})
		}
	}
	lazy var mainCollectionView:UICollectionView = {
		let layout:UICollectionViewLeftFlowLayout = UICollectionViewLeftFlowLayout.init()
		layout.minimumLineSpacing = 15
		layout.minimumInteritemSpacing = 15
		layout.scrollDirection = .vertical
		
		let collectionV:UICollectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: SWScreen_width, height: 1), collectionViewLayout: layout)
		
		collectionV.register(UINib.init(nibName: "MarketsSearchCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MarketsSearchCollectionViewCell")
		collectionV.delegate = self
		collectionV.dataSource = self
		
		return collectionV
	}()
	
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.contentView.addSubview(mainCollectionView)
		mainCollectionView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.contentView);
            make.height.equalTo(mainCollectionView.collectionViewLayout.collectionViewContentSize.height)

		}
		mainCollectionView.backgroundColor = superview?.backgroundColor
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func didMoveToSuperview() {
		superview?.didMoveToSuperview()
		self.contentView.backgroundColor = superview?.backgroundColor
		mainCollectionView.backgroundColor = superview?.backgroundColor
	}
	
	//delegate & datasource
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //历史记录如果超过15条，默认只显示15条
        return dataArr.count > 15 ? 15 : dataArr.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell:MarketsSearchCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarketsSearchCollectionViewCell", for: indexPath) as! MarketsSearchCollectionViewCell
		if indexPath.item < dataArr.count {
			cell.title.text = dataArr[indexPath.item]
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if indexPath.item < dataArr.count {
			let title:NSString = dataArr[indexPath.item] as NSString
			let size = title.boundingRect(with: CGSize.init(width: 0, height: 32), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)], context: nil).size
			
			return CGSize.init(width: Int(ceilf(Float(size.width)) + 24), height: 32)
		}
		return CGSize.init(width: 56, height: 32)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let title:NSString = dataArr[indexPath.item] as NSString

        self.delegate?.didSelectItem(symbol: title as String)
	}
}
