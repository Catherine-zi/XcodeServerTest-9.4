//
//  MarketsNavBarView.swift
//  SwiftWallet
//
//  Created by Selin on 2018/6/27.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import PagingMenuController

fileprivate let menuItemTitleColor: UIColor = UIColor.init(red: 153, green: 153, blue: 153)
fileprivate let menuItemTitleFont: UIFont = UIFont.boldSystemFont(ofSize: 15)
fileprivate let menuViewBackgroundColor: UIColor = UIColor.init(red: 53, green: 106, blue: 246)



private struct PagingMenuOptions: PagingMenuControllerCustomizable {
    
    
    private let favoriteVC = FavoritesViewController()
    private let allVC = AllViewController()
    private let exchangeVC = ExchangeViewController()
    
    fileprivate var pagingControllers: [UIViewController] {
        return [favoriteVC, allVC, exchangeVC]
    }
    
    fileprivate var componentType: ComponentType {
        return .all(menuOptions: MarketsMenuOptions(), pagingControllers: pagingControllers)
    }
    fileprivate var isScrollEnabled: Bool = false
    
    fileprivate struct MarketsMenuOptions: MenuViewCustomizable {
        
        var displayMode: MenuDisplayMode {
            return .standard(widthMode: MenuItemWidthMode.fixed(width: (SWScreen_width-12.5*9)/3), centerItem: false, scrollingMode: MenuScrollingMode.scrollEnabledAndBouces) //MenuItemWidthMode.fixed...???怎么设置都不对
        }
        var animationDuration: TimeInterval = 0.15
        
        var isScrollEnabled: Bool = false
        
        
        var height: CGFloat = 44
        
        var focusMode: MenuFocusMode{
            return .roundRect(radius: 4, horizontalPadding: 12.5, verticalPadding: 8, selectedColor: menuViewBackgroundColor)
        }
        
        var itemsOptions: [MenuItemViewCustomizable] {
            return[MenuItem1(), MenuItem2(), MenuItem3()]
        }
        //        SWLocalizedString(key: "assets_import_text")
        fileprivate struct MenuItem1: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode{
                return .text(title: MenuItemText.init(text: SWLocalizedString(key: "favorite"), color: menuItemTitleColor, selectedColor: UIColor.white, font: menuItemTitleFont, selectedFont: menuItemTitleFont))//Favorites
            }
        }
        
        fileprivate struct MenuItem2: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode{
                return .text(title: MenuItemText.init(text: SWLocalizedString(key: "coins"), color: menuItemTitleColor, selectedColor: UIColor.white, font: menuItemTitleFont, selectedFont: menuItemTitleFont))
            }
        }
        
        fileprivate struct MenuItem3: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode{
                return .text(title: MenuItemText.init(text: SWLocalizedString(key: "exchange"), color: menuItemTitleColor, selectedColor: UIColor.white, font: menuItemTitleFont, selectedFont: menuItemTitleFont))//Exchange
            }
        }
    }
}

class MarketsNavBarView: UIView {

//    @IBOutlet weak var navTitleLabel: UILabel!
//    @IBOutlet weak var searchBtn: UIButton!
//    @IBOutlet weak var sortingBtn: UIButton!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    let navTitleLabel:UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.init(hexColor: "333333")
        lb.font = UIFont.boldSystemFont(ofSize: 16)
        lb.text = SWLocalizedString(key: "markets")
        return lb
    }()
    
    let searchBtn:UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
        button.setImage(UIImage.init(named: "markets_search"), for: UIControlState.normal)
        button.frame = CGRect.init(x: 0, y: 0, width: 34, height: 34)
        return button
    }()
    
    let screeningBtn:UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
        button.frame = CGRect.init(x: 0, y: 0, width: 34, height: 34)
        button.setImage(UIImage.init(named: "markets_screening"), for: UIControlState.normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.addSubview(navTitleLabel)
        self.addSubview(searchBtn)
//        self.addSubview(screeningBtn)
        
        
//        navTitleLabel.snp.makeConstraints { (make) in
//            make.centerY.equalTo(self).offset(15)
//            make.centerX.equalTo(self)
//        }
        searchBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(self).offset(15)
            make.trailing.equalTo(self).offset(-5)
            make.width.height.equalTo(40)
        }
//        screeningBtn.snp.makeConstraints { (make) in
//            make.centerY.equalTo(self).offset(15)
//            make.trailing.equalTo(searchBtn.snp.leading).offset(0)
//            make.width.height.equalTo(40)
//        }
        let options = PagingMenuOptions()
        let pagingMenuController = PagingMenuController(options:options)
//                pagingMenuController.view.frame.origin.y += SafeAreaTopHeight
                pagingMenuController.view.frame.size.height -= SafeAreaTopHeight
        self.viewController().addChildViewController(pagingMenuController)
        self.viewController().view.addSubview(pagingMenuController.view)
        //        pagingMenuController.onMove = { state in
        //            switch state {
        //            case let .didMoveController(toVC, _):
        //                self.navBarView.screeningBtn.isHidden = toVC is AllViewController ? false : true
        //                if toVC.isKind(of: FavoritesViewController.self) {
        //                    let vc:FavoritesViewController = toVC as! FavoritesViewController
        //                    vc.aotuRefreshData()
        //                }
        //                break
        
        //            default:
        //                break
        //            }
        //        }
        pagingMenuController.didMove(toParentViewController: self.viewController())
//        pagingMenuController.view.snp.makeConstraints { (make) in
//            make.top.equalTo(self)
//            make.bottom.equalTo(self)
//            make.centerX.equalTo(self)
//            make.width.equalTo(SWScreen_width-120)
//        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
