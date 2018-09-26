//
//  MarketsViewController.swift
//  SwiftWallet
//
//  Created by Jack on 13/03/2018.
//  Copyright © 2018 DotC United Group. All rights reserved.
//

import UIKit
import PagingMenuController

@objc public class MarketsViewController: UIViewController, SwipeMenuViewDelegate, SwipeMenuViewDataSource {
    
    var swipeMenuView: SwipeMenuView!
    
    private let favoriteVC = FavoritesViewController()
    private let allVC = AllSuperViewController()//AllViewController()
    private let exchangeVC = ExchangeSuperViewController()//ExchangeViewController()
    
    private let searchBtn:UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
        button.setImage(UIImage.init(named: "markets_search"), for: UIControlState.normal)
        button.frame = CGRect.init(x: SWScreen_width-34-5, y:  (44-34)/2, width: 44, height: 44)
        button.addTarget(self, action: #selector(clickSearchBtn), for: .touchUpInside)
        return button
    }()
    
    private let alertBtn:UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
//        button.isHirdden = true
        button.setImage(UIImage.init(named: "iconalert"), for: UIControlState.normal)
        button.frame = CGRect.init(x: SWScreen_width-34-5, y:  (44-34)/2, width: 44, height: 44)
        button.addTarget(self, action: #selector(clickAlertBtn), for: .touchUpInside)
        return button
    }()
    
	override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Markets_TabBar)//打点
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_MyAlert_MarketsPage)
        
        _ = SwiftExchanger.shared
        _ = SwiftNotificationManager.shared
        
        self.loadViewControllers()
        
        swipeMenuView = SwipeMenuView(frame: view.frame)
        swipeMenuView.leftView = alertBtn
        swipeMenuView.rightView = searchBtn
        swipeMenuView.delegate = self
        swipeMenuView.dataSource = self
        view.addSubview(swipeMenuView)
        
        var options: SwipeMenuViewOptions = .init()
        options.tabView.style = .segmented
        options.tabView.height = 44
        options.tabView.additionView.backgroundColor = .init(hexColor: "1e59f5")
        let additionInset = 0.5 * ((SWScreen_width - self.alertBtn.bounds.width - self.searchBtn.bounds.width) / 3 - 20/* 下划线宽度 */)
        options.tabView.additionView.padding = UIEdgeInsets.init(top: 0, left: additionInset, bottom: 4, right: additionInset)
//        options.tabView.additionView.backgroundColor  = UIColor.customUnderlineColor
//        options.tabView.itemView.textColor            = UIColor.customTextColor
        options.tabView.itemView.selectedTextColor = .init(hexColor: "1e59f5")
        swipeMenuView.reloadData(options: options, default: 0, isOrientationChange: false)
        
//        self.loadViews()
//        self.loadViewControllers()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            if self.view.safeAreaLayoutGuide.layoutFrame != .zero {
                swipeMenuView.frame = self.view.safeAreaLayoutGuide.layoutFrame
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func clickSearchBtn() {
        let vc:MarketsSearchViewController = MarketsSearchViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
	@objc func clickAlertBtn() {
		
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_MyAlert_MarketsPage)
		let alertVC = AlertListViewController()
		alertVC.hidesBottomBarWhenPushed = true
		self.navigationController?.pushViewController(alertVC, animated: true)
		
	}
    
    private func loadViewControllers() {
        favoriteVC.title = SWLocalizedString(key: "favorite")
        allVC.title = SWLocalizedString(key: "coins")
        exchangeVC.title = SWLocalizedString(key: "exchange")
        self.addChildViewController(favoriteVC)
        self.addChildViewController(allVC)
        self.addChildViewController(exchangeVC)
    }
    
    public func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return self.childViewControllers.count
    }
    
    public func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return self.childViewControllers[index].title ?? ""
    }
    
    public func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        return self.childViewControllers[index]
    }
   
    deinit {
        
    }
}






