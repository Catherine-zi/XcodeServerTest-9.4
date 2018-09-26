//
//  AllSuperViewController.swift
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/8/23.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit
import PKHUD

let coinSortingArrayStoreKey = "coinSortingArray"
var coinSortingKeyArray: [String: String] = {
    var array: [String: String] = [:]
    if let arr = UserDefaults.standard.value(forKey: coinSortingArrayStoreKey) as? [String: String] {
        array = arr
    }
    return array
}()

class AllSuperViewController: UIViewController, SwipeMenuViewDelegate, SwipeMenuViewDataSource, AllChildDelegate {
    
    var swipeMenuView: SwipeMenuView!
    var options: SwipeMenuViewOptions!
    private var pairDic: Dictionary<String, [String]>?
    private var pairTagList:[String] = []
    private var moreTagList:[String] = []
//    private var childVCArray:[String:AllChildViewController] = [:]
    
    private lazy var networkFailView: UIView = {
        let failView : NetworkFailView = Bundle.main.loadNibNamed("NetworkFailView", owner: nil, options: nil)?.first as! NetworkFailView
        failView.tryButton.addTarget(self, action: #selector(touchTryAgain), for: .touchUpInside)
        failView.tipsLabel.text = SWLocalizedString(key: "load_failed")

        return failView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(hexColor: "F8F8F8")
        
        getCoinPairTagList()
        
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_All_Page)
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Coins_HomePage)
        
//        self.loadViewControllers()
        
        swipeMenuView = SwipeMenuView(frame: view.frame)
        swipeMenuView.delegate = self
        swipeMenuView.dataSource = self
        swipeMenuView.reuseVCClass = AllChildViewController.self
        view.addSubview(swipeMenuView)
        
        var addBtn:UIButton = UIButton()
        addBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        addBtn.setImage(#imageLiteral(resourceName: "iconadd"), for: .normal)
        addBtn.setBackgroundImage(UIImage.init(color: UIColor.init(hexColor: "f2f2f2")), for: .normal)
        addBtn.addTarget(self, action: #selector(addButtonAction(addBtn:)), for: .touchUpInside)
        swipeMenuView.rightView = addBtn
        
        options = SwipeMenuViewOptions.init()
        options.tabView.style = .flexible
        options.tabView.height = 35
        options.tabView.backgroundColor  = UIColor.init(hexColor: "f2f2f2")
        options.tabView.margin = 10
        options.tabView.spacing = 10
        options.tabView.itemView.font = UIFont.systemFont(ofSize: 12)
        options.tabView.itemView.selectedFont = UIFont.boldSystemFont(ofSize: 12)
        options.tabView.itemView.textColor = UIColor.init(hexColor: "bbbbbb")
        options.tabView.itemView.selectedTextColor = UIColor.init(hexColor: "1e59f5")
        options.tabView.itemView.backgroundColor = UIColor.clear
        options.tabView.itemView.margin = 20
        options.tabView.addition = .circle
        options.tabView.additionView.circle.cornerRadius = 4
        options.tabView.additionView.circle.height = 22
        options.tabView.additionView.backgroundColor  = UIColor.clear//init(hexColor: "1e59f5")
        swipeMenuView.reloadData(options: options, default: 0, isOrientationChange: false)
        
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
    
    public func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return self.pairTagList.count
    }
    
    public func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return self.pairTagList[index]
    }
    
    public func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
//        if index < self.pairTagList.count {
//            if let vc = self.childVCArray[self.pairTagList[index]] {
//                return vc
//            }
//        }
//        let newVC = AllChildViewController()
//        newVC.currentClickCoinKey = self.pairTagList[index]
//        self.addChildViewController(newVC)
//        self.childVCArray[self.pairTagList[index]] = newVC
//        return newVC
        if let vc = swipeMenuView.dequeueReuseVC(index: index) as? AllChildViewController {
            if !self.childViewControllers.contains(vc) {
                self.addChildViewController(vc)
            }
            vc.currentClickCoinKey = self.pairTagList[index]
            if swipeMenuView.currentIndex == index {
                if vc.isShowTagWithAll {
                    SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_All_Coins_HomePage)
                } else {
                    SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_ETH_Pairs_HomePage)
                }
            }
            if vc.delegate == nil {
                vc.delegate = self
            }
            return vc
        }
        return UIViewController()
    }
    
    func allChildDidSelect(child: AllChildViewController, vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func getCoinPairTagList() {
        if let tagArrayArray = UserDefaults.standard.value(forKey: marketTagKeyPrefix + "pair") as? [[String]] {
            if tagArrayArray.count == 2 {
                self.pairTagList = tagArrayArray[0]
                self.moreTagList = tagArrayArray[1]
            }
            
        }
        
        if pairTagList.count != 0 {
//            loadDataView()
//            swipeMenuView.reloadData(options: options, default: 0, isOrientationChange: false)
        } else {
            requestPairTagList()
        }
    }
    
    //MARK: - Request Network
    func requestPairTagList() {
        MarketsAPIProvider.request(MarketsAPI.markets_pairsTags) { [weak self](result) in
            if case let .success(response) = result {
                let decryptedData:Data = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(MarketsTitleTagsStruct.self, from: decryptedData)
                if json?.code != 0 {
                    self?.loadFailedView()
                    print("markets all response json: \(String(describing: json ?? nil))")
                    return
                }
                if json?.data == nil { return }
                
                DispatchQueue.main.async {
                    self?.networkFailView.removeFromSuperview()

                    self?.pairDic = json?.data
                    
                    let pairTags:[String]? = self?.pairDic!["pair"]
                    if pairTags != nil && pairTags?.count != 0 {
                        self?.pairTagList = pairTags!
                    }
                    
                    let moreTags:[String]? = self?.pairDic!["more_tags"]
                    if moreTags != nil && moreTags?.count != 0 {
                        self?.moreTagList = moreTags!
                    }
                    self?.swipeMenuView.reloadData(options: self?.options, default: 0, isOrientationChange: false)
                }
            } else {
                //                print(result)
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
                
                self?.loadFailedView()
            }
        }
    }
    
    func loadFailedView() {
        
        view.addSubview(networkFailView)
        networkFailView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
        }
    }
    @objc func touchTryAgain() {
        getCoinPairTagList()
        
    }
    @objc func addButtonAction(addBtn: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_ManageTag_Pairs_HomePage)
        
        let customVC : TagManageViewController = TagManageViewController()
        customVC.type = MarketTagType.pair
        for tag in pairTagList {
            customVC.myTagArray.append(tag)
        }
        for tag in moreTagList {
            customVC.moreTagArray.append(tag)
        }
        customVC.hidesBottomBarWhenPushed = true
        customVC.reloadHeadTagBlock = { [weak self] (pairTagList, moreList) in
            self?.pairTagList = pairTagList
            self?.moreTagList = moreList
            self?.swipeMenuView.reloadData(options: self?.options, default: 0, isOrientationChange: false)
        }
        navigationController?.pushViewController(customVC, animated: true)
    }
    
    //MARK: - dealloc
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

    

