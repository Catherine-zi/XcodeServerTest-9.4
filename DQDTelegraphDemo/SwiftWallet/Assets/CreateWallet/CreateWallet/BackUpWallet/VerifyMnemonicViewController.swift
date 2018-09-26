//
//  VerifyMnemonicViewController.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/4.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import PKHUD
class VerifyMnemonicViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
  
    var walletModel:SwiftWalletModel? {
        didSet {
            guard let encryptData = self.walletModel?.mnemonic,
                let encryptPassword = self.walletModel?.password,
                let password = SwiftWalletManager.shared.normalDecrypt(string: encryptPassword),
                let decryptData = SwiftWalletManager.shared.customDecrypt(data: encryptData, key: password),
                let newMne = try? JSONDecoder().decode([String].self, from: decryptData)
            else {
                return
            }
            mnemonic = newMne
            let arr:[Int] = CreateRandomList.getRandomList(randomCount: 12)
            for i in arr {
                randomMnemonic.append(newMne[i])
            }
        }
    }

	var topCollectionH:CGFloat = 0 {
		didSet {
			if (self.topCollectionConsH != nil) {
				self.topCollectionConsH.constant = topCollectionH
			}
		}
	}
    
    var mnemonic:[String]?
//    var mnemonic:[String]?{
//
//        didSet {
//
//            guard let newMne = mnemonic else {
//
//                return
//            }
//            let arr:[Int] = CreateRandomList.getRandomList(randomCount: 12)
//
//            for i in arr {
//                randomMnemonic.append(newMne[i])
//            }
//        }
//    }

	//for select collectionView
	var randomMnemonic:[String] = []
	//for show
	var selectMnemonic:[String] = []
	
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    
    
	@IBOutlet weak var grayBackView: UIView!
	@IBOutlet weak var topCollectionView: UICollectionView!
	@IBOutlet weak var nextBtn: UIButton!
	
	@IBAction func clickNextBtn(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Confirm_VerifyMnemonic_Page)
		//judge
		if selectMnemonic == self.mnemonic {
			
			let visual = VisualEffectView.visualEffectView(frame: view.bounds)
			let successView = Bundle.main.loadNibNamed("BackUpSuccessView", owner: nil, options: nil)?.first as! BackUpSuccessView
			successView.frame = VisualEffectView.subFrame
			visual.contentView.addSubview(successView)
			view.addSubview(visual)
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Backup_Success_Popup)
			
			successView.confirmBlock = {[weak visual,weak self] in
				visual?.removeFromSuperview()
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Understand_Backup_Success_Popup)
				
                self?.walletModel?.isBackUp = true
                SwiftWalletManager.shared.storeWalletArr()
				NotificationCenter.post(customeNotification: SWNotificationName.backWalletSucces)
				//跳到资产页
				self?.gotoAssetVc()
			}
		}else {
			
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Backup_failure_Prompt)
			self.noticeOnlyText(SWLocalizedString(key: "fail_to_backup"))
		}
		
	}
	@IBAction func clickBackBtn(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_VerifyMnemonic_Page)
		self.navigationController?.popViewController(animated: true)
	}
	@IBOutlet weak var topCollectionConsH: NSLayoutConstraint!
	
	override func viewDidLoad() {
		super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_VerifyMnemonic_Page)
		//		if #available(iOS 11.0, *) {
		//			topCollectionView.contentInsetAdjustmentBehavior = .never
		//		} else {
		//			self.automaticallyAdjustsScrollViewInsets = false
		//		}
		setUpViews()
	}
	
	private func setUpViews() {
		self.navTitleLabel.text = SWLocalizedString(key: "wallet_buckup_title")
        self.tipsLabel.text = SWLocalizedString(key: "wallet_backup_verify_message")
        self.nextBtn.setTitle(SWLocalizedString(key: "wallet_next_setp"), for: .normal)
		
		addMnemonicCollection()
		addShowCollection()
		
		//remove GenerateMnemonicViewController
		if let nav = self.navigationController {
			for (index,vc) in nav.viewControllers.enumerated() {
				if vc.isKind(of: GenerateMnemonicViewController.classForCoder()) {
					nav.viewControllers.remove(at: index)
					break
				}
			}
		}
	}
	
	private func gotoAssetVc() {
        if self.tabBarController != nil {
            if self.tabBarController?.selectedIndex != 2 {
                for vc in (self.navigationController?.viewControllers)! {
                    if vc.isKind(of: ManageWalletViewController.classForCoder()) {
                        self.navigationController?.popToViewController(vc, animated: true)
                    }
                }
            } else {
                if self.navigationController != nil {
                    self.navigationController?.viewControllers = [AssetstViewController()]
                }
            }
        }
	}
	
	//UICollectionViewDataSource & ..
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == topCollectionView {
			return selectMnemonic.count
		}
		return randomMnemonic.count
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if collectionView == topCollectionView {
			let cell:CreateMnemonicMCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateMnemonicMCell", for: indexPath) as! CreateMnemonicMCell
			
			if indexPath.item < selectMnemonic.count {
				cell.titleL.text = selectMnemonic[indexPath.item]
			}
			return cell
		}
		
		//bottom
		let cell:SelectMnemonicCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectMnemonicCell", for: indexPath) as! SelectMnemonicCell
		if indexPath.item < randomMnemonic.count {
			cell.titleL.text = randomMnemonic[indexPath.item]
		}
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		if collectionView == topCollectionView {
			return
		}
		
		//select
		let cell:SelectMnemonicCell = collectionView.cellForItem(at: indexPath) as! SelectMnemonicCell
		if cell.isSelectedCell {
			//remove on dataArr
			let str = cell.titleL.text
			selectMnemonic = selectMnemonic.filter{ $0 != str }
			nextBtn.isEnabled = false
		} else {
			let str = cell.titleL.text
			selectMnemonic.append(str!)
			if selectMnemonic.count == self.mnemonic?.count {
				nextBtn.isEnabled = true
			}
		}
		topCollectionView.reloadData()
		cell.isSelectedCell = !cell.isSelectedCell
	}
	
	//UICollectionViewFlowLayout
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

		var title:String = ""
		if collectionView == topCollectionView {
			if (indexPath.item < selectMnemonic.count){
				title = selectMnemonic[indexPath.item]
			}
		}else {
			if (indexPath.item < randomMnemonic.count){
				title = randomMnemonic[indexPath.item]
			}
		}
		return calculateSize(title: title,colletionV: collectionView)
	
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		
		if collectionView == topCollectionView {
			return UIEdgeInsets.init(top: 10, left: 16, bottom: 20, right: 16)
		}
		return UIEdgeInsets.init(top: 31, left: 0, bottom: 0, right: 0)
	}
	
	func calculateSize(title:String,colletionV:UICollectionView) -> CGSize {
		
		let str:NSString = title as NSString
		let size:CGSize = str.boundingRect(with: CGSize.init(width: 0, height: 20), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15),NSAttributedStringKey.foregroundColor : UIColor.blue], context: nil).size
		
		if colletionV == topCollectionView {
			return CGSize.init(width: size.width + 2, height: size.height)
		}
		return CGSize.init(width: size.width + 30 + 2, height: size.height + 20)
	}

	
	
	//setup views
	private func addMnemonicCollection() {
		let flowlayout:UICollectionViewLeftFlowLayout = UICollectionViewLeftFlowLayout.init()
		flowlayout.minimumLineSpacing = 15
		flowlayout.minimumInteritemSpacing = 25
		flowlayout.scrollDirection = .vertical
		
		
		topCollectionView.setCollectionViewLayout(flowlayout, animated: false)
		topCollectionView.dataSource = self
		topCollectionView.delegate = self
		topCollectionView.register(UINib.init(nibName: "CreateMnemonicMCell", bundle: nil), forCellWithReuseIdentifier: "CreateMnemonicMCell")
		topCollectionView.layer.cornerRadius = 5
		topCollectionView.layer.masksToBounds = true
		topCollectionView.backgroundColor = UIColor.white
		topCollectionView.bounces = false
	}
	private func addShowCollection() {
		let flowlayout:UICollectionViewLeftFlowLayout = UICollectionViewLeftFlowLayout.init()
		flowlayout.minimumLineSpacing = 10
		flowlayout.minimumInteritemSpacing = 15
		flowlayout.scrollDirection = .vertical
		
		
		let collection:UICollectionView = UICollectionView.init(frame: CGRect.init(x: 16, y: self.topCollectionView.frame.maxY + 10, width: SWScreen_width - 32, height: (UIScreen.main.bounds.size.height - 50 - SafeAreaTopHeight - self.topCollectionView.frame.maxY - 20)), collectionViewLayout: flowlayout)//DynamicHeightCollectionView
		
		collection.dataSource = self
		collection.delegate = self
		collection.register(UINib.init(nibName: "SelectMnemonicCell", bundle: nil), forCellWithReuseIdentifier: "SelectMnemonicCell")
		collection.layer.cornerRadius = 5
		collection.layer.masksToBounds = true
		collection.backgroundColor = collection.superview?.backgroundColor
		collection.bounces = false
		
		grayBackView.addSubview(collection)
	}

}
