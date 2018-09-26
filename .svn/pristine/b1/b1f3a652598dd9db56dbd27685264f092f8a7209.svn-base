//
//  AssetsTopView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/20.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

let assetsTopSpecialViewH:CGFloat = 251 + SafeAreaTopHeight
let assetsTopNormalViewH:CGFloat  = UIScreen.main.nativeBounds.height >= 2436 ? 100 : 80
let bottomInsetOffset:CGFloat = 85
let assetsNeedMinContentSize:CGFloat = (SWScreen_height - assetsTopNormalViewH - bottomInsetOffset)
class AssetsTopView: UIView,UIScrollViewDelegate {

	var headScrollView:UIScrollView?
	lazy var normalTopView:AssetsTopNormalView = {
		let top:AssetsTopNormalView = Bundle.main.loadNibNamed("AssetsTopNormalView", owner: nil, options: nil)?.first as! AssetsTopNormalView
        var height = assetsTopNormalViewH
		top.frame = CGRect.init(x: 0, y: 0, width: SWScreen_width, height: assetsTopNormalViewH)
//		top.alpha = 0.0
		return top
	}()

	lazy var specialTopView:AssetsTopCollectionView = {
		let specialTopView = Bundle.main.loadNibNamed("AssetsTopCollectionView", owner: nil, options: nil)?.first as! AssetsTopCollectionView
		
		if #available(iOS 11.0, *) {
			specialTopView.frame = CGRect.init(x: 0, y: 0, width: SWScreen_width, height: assetsTopSpecialViewH)
		}else {
			specialTopView.frame = CGRect.init(x: 0, y: 20, width: SWScreen_width, height: assetsTopSpecialViewH - 20)
		}
		
		
		return specialTopView
	}()
	typealias ScrollBlock = (Int) -> ()
	var scrollBlock:ScrollBlock? {
		didSet {
			specialTopView.scrollBlock = scrollBlock
		}
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.setUpViews()
	}
	
	private func setUpViews(){
		
		
		self.addSubview(specialTopView)
		self.addSubview(normalTopView)
		//get data
		addWalletSuccessNotification()
		
		NotificationCenter.default.addObserver(self, selector: #selector(addWalletSuccessNotification), name: SWNotificationName.addWalletSuccess.notificationName, object: nil)
	}
	@objc func addWalletSuccessNotification() {
		specialTopView.swiftWalletArr = SwiftWalletManager.shared.walletArr
	}
	override func willMove(toSuperview newSuperview: UIView?) {
		
		self.headScrollView?.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
		//这里的scrollView是控制器中的 UITableView，底部偏移是由于 TabBar
		self.headScrollView?.contentInset = UIEdgeInsets.init(top: assetsTopSpecialViewH, left: 0, bottom: 65 + 20, right: 0)
//		self.headScrollView?.delegate = self
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		
		guard let newValue = change else {
			return
		}
		guard let newPoint = newValue[NSKeyValueChangeKey.newKey] as? CGPoint else{
			return
		}
		updateSubViews(newPoint: newPoint)
	}
	func updateSubViews(newPoint:CGPoint){
		
		let startChangeOffset:CGFloat = -assetsTopSpecialViewH//-((self.headScrollView?.contentInset.top)!)
		var topViewOffset:CGFloat = 0
		if newPoint.y < startChangeOffset {
			topViewOffset = 0
		}else{
			topViewOffset = startChangeOffset - newPoint.y
			if topViewOffset < (assetsTopNormalViewH - assetsTopSpecialViewH){
				topViewOffset = assetsTopNormalViewH - assetsTopSpecialViewH
			}
		}
		
		self.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: assetsTopSpecialViewH + topViewOffset)
		normalTopView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: assetsTopNormalViewH)
//		self.headScrollView?.contentInset = UIEdgeInsets.init(top: assetsTopSpecialViewH + topViewOffset, left: 0, bottom: 65 + 20, right: 0)
		let alpha = (-topViewOffset)/(assetsTopSpecialViewH - assetsTopNormalViewH)
		normalTopView.alpha = alpha
		specialTopView.alpha = 1 - alpha
//		print("alpha = \(alpha),frame = \(self.frame),startChangeOffset = \(startChangeOffset)")
	}
	
	
	@objc func addAssetsBtn(sender:UIButton) {
		
		let addAssetsVc:SWAddAssetsViewController = SWAddAssetsViewController()
		self.viewController().navigationController?.pushViewController(addAssetsVc, animated: true)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
