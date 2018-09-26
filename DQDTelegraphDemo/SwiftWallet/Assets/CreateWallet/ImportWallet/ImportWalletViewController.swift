//
//  ImportWalletViewController.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/29.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import PagingMenuController

fileprivate let menuItemTitleColor:UIColor = UIColor.init(red: 153, green: 153, blue: 153)
fileprivate let menuItemTitleFont:UIFont = UIFont.boldSystemFont(ofSize: 15)
fileprivate let menuViewBackgroundColor:UIColor = UIColor.init(red: 53, green: 106, blue: 246)

private struct PagingMenuOptions: PagingMenuControllerCustomizable{
	
	private let vc1 = MnemonicTypeImportWalletVc()
	private let vc2 = PrivateKeyTypeImportWalletVc()
	private let vc3 = KeyStoreTypeImportWalletVc()
	
	fileprivate var componentType: ComponentType {
		return .all(menuOptions: MenuOptions(), pagingControllers: pagingControllers)
	}
	fileprivate var pagingControllers: [UIViewController]{
		return [vc1,vc2]//,vc3
	}
	fileprivate struct MenuOptions:MenuViewCustomizable{
		var displayMode: MenuDisplayMode {
//			return .standard(widthMode: MenuItemWidthMode.flexible, centerItem: true, scrollingMode: MenuScrollingMode.pagingEnabled)
			return .segmentedControl
		}
		var animationDuration: TimeInterval{
			return 0.25
		}
		var height: CGFloat{
			return 44
		}
		
		var focusMode: MenuFocusMode{
			return .roundRect(radius: 4, horizontalPadding: 16, verticalPadding: 8, selectedColor: menuViewBackgroundColor)
		}
		var itemsOptions: [MenuItemViewCustomizable] {
			return [MenuItem1(), MenuItem2()]//,MenuItem3()
		}

		fileprivate struct MenuItem1: MenuItemViewCustomizable {
			var displayMode: MenuItemDisplayMode {
				return .text(title: MenuItemText.init(text: SWLocalizedString(key: "wallet_mnemonic"), color: menuItemTitleColor, selectedColor: UIColor.white, font: menuItemTitleFont, selectedFont: menuItemTitleFont))
			}
		}
		fileprivate struct MenuItem2: MenuItemViewCustomizable {
			var displayMode: MenuItemDisplayMode {
				return .text(title: MenuItemText(text: SWLocalizedString(key: "wallet_privatekey"), color: menuItemTitleColor, selectedColor: UIColor.white, font: menuItemTitleFont, selectedFont: menuItemTitleFont))
			}
		}
		fileprivate struct MenuItem3: MenuItemViewCustomizable {
			var displayMode: MenuItemDisplayMode {
				return .text(title: MenuItemText(text: SWLocalizedString(key: "keystore"), color: menuItemTitleColor, selectedColor: UIColor.white, font: menuItemTitleFont, selectedFont: menuItemTitleFont))
			}
		}
	}
}

class ImportWalletViewController: UIViewController {
    
//    private var scanView: UIView?
    private var pagingMenuController: PagingMenuController = {
        let options = PagingMenuOptions()
        let controller = PagingMenuController(options: options)
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = UIColor.white
//		self.navigationController?.navigationBar.isHidden = true
		
		setUpViews()
		
    }

	func setUpViews(){
		
		//NavView
		addNavView()
		
		//pagingMenuVeiwController
//        let options = PagingMenuOptions()
//        pagingMenuController = PagingMenuController(options: options)
		pagingMenuController.view.frame.origin.y += SafeAreaTopHeight
		pagingMenuController.view.frame.size.height -= SafeAreaTopHeight
		pagingMenuController.onMove = { state in
			switch state {
			case let .willMoveController(menuController, previousMenuController):
				print(previousMenuController)
				print(menuController)
			case let .didMoveController(menuController, previousMenuController):
				print(previousMenuController)
				print(menuController)
			case let .willMoveItem(menuItemView, previousMenuItemView):
				print(previousMenuItemView)
				print(menuItemView)
			case let .didMoveItem(menuItemView, previousMenuItemView):
				print(previousMenuItemView)
				print(menuItemView)
			case .didScrollStart:
				print("Scroll start")
				UIApplication.shared.keyWindow?.endEditing(false)
			case .didScrollEnd:
				print("Scroll end")
			}
		}
		
		addChildViewController(pagingMenuController)
		view.addSubview(pagingMenuController.view)
		pagingMenuController.didMove(toParentViewController: self)
	}
	
	private func addNavView(){
		let navView:UIView = UIView.init(frame: CGRect.init(x: 0, y: SWStatusBarH, width: SWScreen_width, height: SWNavBarHeight))
		self.view.addSubview(navView)
		
		let backBtn:UIButton = UIButton.init()
		backBtn.addTarget(self, action: #selector(back), for: UIControlEvents.touchUpInside)
		backBtn.setImage(UIImage.init(named: "addAssets_back"), for: UIControlState.normal)
		
		let title:UILabel = UILabel.init()
		title.text = SWLocalizedString(key: "assets_import_text")
        
        let scanBtn:UIButton = UIButton.init()
        scanBtn.addTarget(self, action: #selector(scan), for: UIControlEvents.touchUpInside)
        scanBtn.setImage(UIImage.init(named: "TransferAccounts_scanIcon"), for: UIControlState.normal)
		
		navView.addSubview(backBtn)
        navView.addSubview(scanBtn)
		navView.addSubview(title)
		
		backBtn.snp.makeConstraints { (make) in
			make.left.equalTo(navView).offset(16)
			make.centerY.equalTo(navView)
			make.height.width.equalTo(44)
		}
        scanBtn.snp.makeConstraints { (make) in
            make.right.equalTo(navView).offset(-16)
            make.centerY.equalTo(navView)
            make.height.width.equalTo(44)
        }
		title.snp.makeConstraints { (make) in
			make.centerY.centerX.equalTo(navView)
		}
		
	}
	
	@objc private func back(){
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_ImportWallet_Page)
		self.navigationController?.popViewController(animated: true)
	}
    
    @objc private func scan(){
        for (_, vc) in self.pagingMenuController.childViewControllers[0].childViewControllers.enumerated() {
            vc.view.endEditing(true)
        }
        let scanVC = ScanViewController()
        scanVC.completeBlock = {(scanStr) -> () in
            scanVC.dismiss(animated: true, completion: {
                for (index, vc) in self.pagingMenuController.childViewControllers[0].childViewControllers.enumerated() {
                    if vc is PrivateKeyTypeImportWalletVc {
                        self.pagingMenuController.move(toPage: index, animated: false)
                        let privVC = vc as! PrivateKeyTypeImportWalletVc
                        privVC.scanString = scanStr
                    }
                }
            })
        }
        self.present(scanVC, animated: true, completion: nil)
//        if self.scanView == nil {
//            weak var weakSelf = self
//            self.scanView = UIView.init(frame: self.view.bounds)
//            let scan = BTCQRCode.scannerView { (address) in
//                weakSelf?.dealScanView(scanText: address!)
//            }
//            scan?.frame = (weakSelf?.view.bounds)!
//            scanView?.addSubview(scan!)
//
//            let closeBtn = UIButton.init(frame: CGRect.init(x: 0, y: (weakSelf?.view.frame.height)! - 50, width: (weakSelf?.view.frame.width)!, height: 50))
//            closeBtn.setTitle("Close", for: .normal)
//            closeBtn.setBackgroundImage(UIImage.init(color: UIColor.init(hexColor: "1e59f5")), for: .normal)
//            closeBtn.addTarget(weakSelf, action: #selector(dismissScanView), for: .touchUpInside)
//            scanView?.addSubview(closeBtn)
//        }
//        self.view.addSubview(scanView!)
    }
    
//    private func dealScanView(scanText: String) {
//        self.dismissScanView()
//        for (index, vc) in self.pagingMenuController.childViewControllers[0].childViewControllers.enumerated() {
//            if vc is PrivateKeyTypeImportWalletVc {
//                self.pagingMenuController.move(toPage: index, animated: false)
//                let privVC = vc as! PrivateKeyTypeImportWalletVc
//                privVC.scanString = scanText
//            }
//        }
////        self.addressTextField.text = scanText
//    }
//
//    @objc private func dismissScanView() {
//        self.scanView?.removeFromSuperview()
//    }

}
