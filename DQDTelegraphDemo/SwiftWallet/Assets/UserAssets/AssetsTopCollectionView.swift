//
//  AssetsTopCollectionView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/23.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class AssetsTopCollectionView: UIView,UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate {
	
	let popView:AssetsMoreBtnPopView = Bundle.main.loadNibNamed("AssetsMoreBtnPopView", owner: nil, options: nil)?.first as! AssetsMoreBtnPopView
	
//    var walletBackImageNameArr:[String] = []
	var swiftWalletArr:[SwiftWalletModel] = [] {
		didSet {
//            walletBackImageNameArr = CreateRandomColorForWallet.getRandomColorForWallet(randomCount: swiftWalletArr.count)
			collectionView.reloadData()
			pageControl.numberOfPages = swiftWalletArr.count
			pageControl.isHidden = true
//			if swiftWalletArr.count > 0 {
//				collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionViewScrollPosition.left, animated: true)
//				pageControl.currentPage = 0
//				if scrollBlock != nil {
//					scrollBlock!(0)
//				}
//			}
		}
	}
	typealias ScrollBlock = (Int) -> ()
	var scrollBlock:ScrollBlock?	
	
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
//	@IBOutlet weak var flowLayout: CustomPagingSizeLayout!
	@IBOutlet weak var pageControl: UIPageControl!
	@IBOutlet weak var flowLayout: CustomPagingSizeLayout!
	
	
	@IBAction func clickPage(_ sender: UIPageControl) {
		print("sender.currentPage = \(sender.currentPage)")
	}
	@IBAction func clickMoreBtns(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_FloatingLayer_AssetsPage)
		if popView.superview != nil {
			popView.superview?.removeFromSuperview()
		}else{
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_FloatingLayer_AssetsPage)
			var frame = sender.frame
			frame = CGRect(x: sender.frame.origin.x - 157 + 20, y: SafeAreaTopHeight, width: 157, height: 240)
			let window:UIWindow = ((UIApplication.shared.delegate?.window)!)!
			popView.frame = frame
			
			let backV:UIView = UIView(frame: window.bounds)
			backV.backgroundColor = UIColor.clear
			window.addSubview(backV)
			let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(clickTap))
			
			weak var weakSelf = self
			tap.delegate = weakSelf
			backV.addGestureRecognizer(tap)
			backV.addSubview(popView)
		}
	}
	
	@objc private func clickTap() {
		popView.superview?.removeFromSuperview()
	}

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		if (touch.view?.superview?.isKind(of: UITableViewCell.classForCoder()))! {
			return false
		}
		return true
	}
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setUpViews()
		popView.clickPopViewBlock = {[weak self](count:Int) in
			
			let vc:UIViewController?
			switch count {
            case 0: vc = WatchWalletViewController()
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_WatchWallet_FloatingLayer)
			case 1: vc = ImportWalletViewController()
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_ImportWallet_FloatingLayer)
			case 2: vc = CreateWalletDetailViewController()
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_CreateWallet_FloatingLayer)
			case 3: let tempVC = ScanViewController()
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Scan_FloatingLayer)
                tempVC.completeBlock = { (scanStr) -> () in
                    let sendVC = TransferAccountsViewController.init(nibName: "TransferAccountsViewController", bundle: nil)
                    sendVC.destinationAddress = scanStr
                    self?.viewController().present(sendVC, animated: true) {
                        self?.viewController().navigationController?.popViewController(animated: false)
                    }
                }
                vc = tempVC
			default:
				vc = UIViewController()
			}
			vc?.hidesBottomBarWhenPushed = true
            let animated = vc is ScanViewController ? false : true
			self?.viewController().navigationController?.pushViewController(vc!, animated: animated)
		}
	}

	
	
	private func setUpViews() {
		self.navTitleLabel.text = SWLocalizedString(key: "assets")
        self.backgroundColor = UIColor.init(hexColor: "F2F2F2")
		
		let customLayout:CustomPagingSizeLayout = CustomPagingSizeLayout()
		
		customLayout.itemSize = CGSize(width: collectionCellW, height: 235)
		customLayout.scrollDirection = .horizontal
		customLayout.minimumLineSpacing = 0
		customLayout.minimumInteritemSpacing = 0
		
		collectionView.setCollectionViewLayout(customLayout, animated: false)
		collectionView.contentInset = UIEdgeInsetsMake(0, 23, 0, 23)
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.register(UINib.init(nibName: "AssetsTopCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AssetsTopCollectionViewCell")
//		collectionView.isPagingEnabled = true
		collectionView.backgroundColor = UIColor.init(hexColor: "F2F2F2")
//		collectionView.decelerationRate = UIScrollViewDecelerationRateFast
		pageControl.backgroundColor = collectionView.backgroundColor
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.bounces = false
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return swiftWalletArr.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetsTopCollectionViewCell", for: indexPath) as! AssetsTopCollectionViewCell
        if indexPath.item < swiftWalletArr.count {//}&& indexPath.item < (walletBackImageNameArr.count){
			cell.model = swiftWalletArr[indexPath.item]
//            cell.backImageV.image = UIImage(named: walletBackImageNameArr[indexPath.item])
		}
		
		return cell
	}
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_AssetsCard_Assets_Page)
        let walletVC = WalletDetailViewController()
        walletVC.walletModel = swiftWalletArr[indexPath.item]
        walletVC.hidesBottomBarWhenPushed = true
        self.viewController().navigationController?.pushViewController(walletVC, animated: true)
    }
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if(!decelerate) {
			collectionViewShowMainCell(scrollView: scrollView)
		}
	}
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		collectionViewShowMainCell(scrollView: scrollView)
	}
	
	private let collectionCellW:CGFloat = (SWScreen_width - 23 * 2)
	private func collectionViewShowMainCell(scrollView: UIScrollView) {
		//get current show's main cell
		 let collectionViewCellW:Int = Int(self.collectionCellW)
		let contentOffsetX = scrollView.contentOffset.x
		let offseet = Int(contentOffsetX) % collectionViewCellW
		
		var num = 0
		if offseet > Int((Double(collectionViewCellW) * 0.5)) {
			num = Int(contentOffsetX) / collectionViewCellW + 1
		}else {
			num = Int(contentOffsetX) / collectionViewCellW
		}
		
		
		pageControl.currentPage = num
		collectionView.scrollToItem(at: IndexPath(item: num, section: 0), at: UICollectionViewScrollPosition.left, animated: true)
		
		if scrollBlock != nil {
//			let model = swiftWalletArr[num]
			scrollBlock!(num)
		}
	}
	
}
