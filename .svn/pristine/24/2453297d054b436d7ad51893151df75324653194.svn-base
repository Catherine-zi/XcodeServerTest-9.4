//
//  AllSuperViewController.swift
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/8/23.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit
import PKHUD

let exchangeSortingArrayStoreKey = "exchangeSortingArray"
var exchangeSortingKeyArray: [String: String] = {
    var array: [String: String] = [:]
    if let arr = UserDefaults.standard.value(forKey: exchangeSortingArrayStoreKey) as? [String: String] {
        array = arr
    }
    return array
}()

class ExchangeSuperViewController: UIViewController, SwipeMenuViewDelegate, SwipeMenuViewDataSource, ExchangChildDelegate {
    
    var swipeMenuView: SwipeMenuView!
    var options: SwipeMenuViewOptions!
    private var exchangeNameDic: Dictionary<String, [String]>?
    private var exchangeNameTagList:[String] = []
    private var exchangeMoreTagList:[String] = []
    var selectedExchangeName = ""
//    private var childVCArray:[String:ExchangeChildViewController] = [:]
    
    private lazy var networkFailView: UIView = {
        let failView : NetworkFailView = Bundle.main.loadNibNamed("NetworkFailView", owner: nil, options: nil)?.first as! NetworkFailView
        failView.tryButton.addTarget(self, action: #selector(touchTryAgain), for: .touchUpInside)
        failView.tipsLabel.text = SWLocalizedString(key: "load_failed")

        return failView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(hexColor: "F8F8F8")
        
        getExchangeTagList()
        
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Exchange_Page)
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_ExHomePage)
        
//        self.loadViewControllers()
        
        swipeMenuView = SwipeMenuView(frame: view.frame)
        swipeMenuView.delegate = self
        swipeMenuView.dataSource = self
        swipeMenuView.reuseVCClass = ExchangeChildViewController.self
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
        options.tabView.itemView.margin = 10
        options.tabView.addition = .circle
        options.tabView.additionView.circle.cornerRadius = 4
        options.tabView.additionView.circle.height = 22
        options.tabView.additionView.backgroundColor  = UIColor.clear//init(hexColor: "1e59f5")
        self.reloadSwipe()
        
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
        return self.exchangeNameTagList.count
    }
    
    public func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return self.exchangeNameTagList[index]
    }
    
    public func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
//        if let vc = self.childVCArray[self.exchangeNameTagList[index]] {
//            return vc
//        }
//        let newVC = ExchangeChildViewController()
//        newVC.exchangeNameTagSelectedKey = self.exchangeNameTagList[index]
//        self.addChildViewController(newVC)
//        self.childVCArray[self.exchangeNameTagList[index]] = newVC
//        return newVC
        if let vc = swipeMenuView.dequeueReuseVC(index: index) as? ExchangeChildViewController {
            if vc.delegate == nil {
                vc.delegate = self
            }
            vc.exchangeNameTagSelectedKey = self.exchangeNameTagList[index]
            return vc
        }
        return UIViewController()
    }
    
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        let exchangeName = self.exchangeNameTagList[toIndex]
        self.selectedExchangeName = exchangeName
    }
    
    func exchangeChildDidSelect(child: ExchangeChildViewController, vc: TransactionPairDetailViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func getExchangeTagList() {
        if let tagArrayArray = UserDefaults.standard.value(forKey: marketTagKeyPrefix + "exchange") as? [[String]] {
            if tagArrayArray.count == 2 {
                self.exchangeNameTagList = tagArrayArray[0]
                self.exchangeMoreTagList = tagArrayArray[1]
            }
        }
        
        requestExchangeNameTagsList()
    }
    
    //MARK: - Request Network
    func requestExchangeNameTagsList() {
        MarketsAPIProvider.request(MarketsAPI.markets_exchangeTags) { [weak self](result) in
            if case let .success(response) = result {
                let decryptedData:Data = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(MarketsExchangeTagModel.self, from: decryptedData)
                if json?.code != 0 {
                    self?.loadFailedView()
                    print("markets all response json: \(String(describing: json ?? nil))")
                    return
                }
                if json?.data == nil { return }
                let tags = json?.data
                //每次对比接口与本地是否有新增tag
                let tagCount = self?.exchangeNameTagList != nil ? self?.exchangeNameTagList.count : 0
                let moreTagCount = self?.exchangeMoreTagList != nil ? self?.exchangeMoreTagList.count : 0
                
                if (tagCount == 0) && (moreTagCount == 0) {
                    self?.exchangeNameTagList = json!.data!
                    
                } else if (tags?.count)! != tagCount! + moreTagCount! {
                    
                    for tag in tags! {
                        if (self?.exchangeNameTagList.contains(tag))! || (self?.exchangeMoreTagList.contains(tag))! {
                            continue
                        } else {
                            self?.exchangeNameTagList.append(tag)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self?.networkFailView.removeFromSuperview()
                    self?.reloadSwipe()
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
        getExchangeTagList()
    }
    @objc func addButtonAction(addBtn: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_ManagerTag_ExHomePage)
        
        let customVC : TagManageViewController = TagManageViewController()
        customVC.type = MarketTagType.exchange
        for tag in exchangeNameTagList {
            customVC.myTagArray.append(tag)
        }
        for tag in exchangeMoreTagList {
            customVC.moreTagArray.append(tag)
        }
        
        customVC.hidesBottomBarWhenPushed = true
        customVC.reloadHeadTagBlock = { [weak self] (tagList, moreTagList) in
            self?.exchangeNameTagList = tagList
            self?.exchangeMoreTagList = moreTagList
            self?.reloadSwipe()
        }
        navigationController?.pushViewController(customVC, animated: true)
    }
    
    private func reloadSwipe() {
        swipeMenuView.reloadData(options: options, default: 0, isOrientationChange: false)
        if self.exchangeNameTagList.count > 0 {
            self.selectedExchangeName = self.exchangeNameTagList[0]
        } else {
            self.selectedExchangeName = ""
        }
    }
    
    //MARK: - dealloc
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

    

