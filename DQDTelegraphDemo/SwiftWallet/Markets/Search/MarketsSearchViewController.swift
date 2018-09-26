//
//  MarketsSearchViewController.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/10.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import PKHUD

class MarketsSearchViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,MarketsSearchCollectionProtocol {
	
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataTipsLabel: UILabel!
    private let reuseID: String = "MarketsSearchTableViewCell"

//    private var resultHeader:SearchResultHeaderView?
    //关键字
	private var currencyRecommendList:[String] = []
    //币种搜索结果
    private var searchCoinsResultList:[SearchMarketContentStruct] = []
    //存贮所有交易对的搜索结果
    private var searchExchangePairsResultDic:Dictionary<String, [SearchExchangePairContentStruct]>?
    //交易所列表
    private var exchangeList:[String] = []
    //某交易所对应交易对列表
    private var exchangePairList:[SearchExchangePairContentStruct] = []
    
    private var selectedExchangeKey:String?
    private var noRefreshExchangeHeader:Bool = false

	private var isShowSearchResult:Bool = false
	private lazy var searchListName:String = {
		return "SearchHistory_Markets" + "UserID" + ".plist"
	}()
	private lazy var searchHistoryPath:NSString = {
		var path:NSString = NSHomeDirectory() as NSString
		path = path.appendingPathComponent("Library/Caches") as NSString
		path = path.appendingPathComponent(self.searchListName) as NSString
		return path
	}()
	private lazy var searchHistoryArr:NSMutableArray = {
		
		var plistArr:NSMutableArray? = NSMutableArray.init(contentsOfFile: self.searchHistoryPath as String)
		if plistArr == nil {
			plistArr = NSMutableArray()
			plistArr?.write(to: URL.init(fileURLWithPath: self.searchHistoryPath as String), atomically: true)
		}
		return plistArr!
	}()
	private lazy var searchNothingsPage:MarketsSearchNothingPage = {
		let page = Bundle.main.loadNibNamed("MarketsSearchNothingPage", owner: nil, options: nil)?.first
		
		return page as! MarketsSearchNothingPage
	}()

	@IBAction func clickBackBtn(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_Search_MarketsPage)

		self.navigationController?.popViewController(animated: true)
	}
	@IBOutlet weak var searchTextField: UITextField!
	@IBOutlet weak var mainTab: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate;
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Search_MarketsPage)

		setUpViews()
		loadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isShowSearchResult == true {
            searchCoinRequest(keyword: searchTextField.text!, pageNo: 0)
        }
    }
    private func setUpViews() {
        searchTextField.placeholder = SWLocalizedString(key: "search_for_coins_tokens_exchange")
        //add searchRightView
        let rightView:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 48, height: 32))
        let slipView:UIView = UIView.init(frame: CGRect.init(x: 0, y: 9, width: 1, height: 14))
        slipView.backgroundColor = UIColor.init(hexColor: "D8D8D8")
        let deleteBtn:UIButton = UIButton.init()
        deleteBtn.setImage(UIImage.init(named: "markets_search_delete"), for: UIControlState.normal)
        deleteBtn.addTarget(self, action: #selector(clickDeleteBtn), for: UIControlEvents.touchUpInside)
        
        rightView.addSubview(slipView)
        rightView.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(rightView)
            maker.centerY.equalTo(rightView)
        }
        rightView.backgroundColor = rightView.superview?.backgroundColor
        let leftView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 15, height: 32))
        leftView.backgroundColor = rightView.superview?.backgroundColor
        searchTextField.leftViewMode = .always
        searchTextField.leftView = leftView
        searchTextField.rightViewMode = .always
        searchTextField.rightView = rightView
        searchTextField.delegate = self
        //setup tab
        mainTab.delegate = self;mainTab.dataSource = self;
        mainTab.register(MarketsSearchTableViewCell.classForCoder(), forCellReuseIdentifier: reuseID)
        mainTab.register(ExchangeResultTableViewCell.classForCoder(), forCellReuseIdentifier: "ExchangeResultTableViewCell")
        mainTab.register(UINib.init(nibName: "MarketsSearchResultCell", bundle: nil), forCellReuseIdentifier: "MarketsSearchResultCell")
        mainTab.backgroundColor = mainTab.superview?.backgroundColor
        mainTab.separatorStyle = .none
        
        //addGesture
        //        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tap))
        //        self.view.addGestureRecognizer(tapGesture)
    }

	private func loadData() {
		SearchAPIProvider.request(SearchAPI.searchCurrencyRecommend) { [weak self](result) in
			if case let .success(response) = result {
                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(CurrencyRecommendStruct.self, from: decryptedData)
				if json?.code != 0 {
					return
				}

                DispatchQueue.main.async {
                    self?.currencyRecommendList.removeAll()
                    for symbol:CurrencySymbolStruct in (json?.data)! {
                        self?.currencyRecommendList.append(symbol.symbol!)
                    }
                    self?.mainTab.reloadData()
                    if self?.currencyRecommendList.count == 0 {
                        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Search_NoResultPage)
                    } else {
                        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Search_ResultPage)
                    }
                }
            } else {
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
            }
		}
	}
    func startSearchCoinAndExchangePairs(keyword: String)  {
        searchCoinRequest(keyword: keyword , pageNo: 0)
        searchExchangePairRequest(keyword: keyword, pageNo: 0)
    }
	//搜索币种接口
    private func searchCoinRequest(keyword: String, pageNo: Int) {
        
        SearchAPIProvider.request(SearchAPI.searchSymbol(keyword, pageNo, 10)) { [weak self](result) in
            if case let .success(response) = result {
                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(SearchMarketStruct.self, from: decryptedData)
                if json?.code != 0 {
//                    HUD.flash(.labeledError(title: json?.msg , subtitle: nil), delay: 1.0)
                    if json?.msg != nil {
                        self?.noticeOnlyText(json!.msg!)
                    }
                    return
                }
                self?.noDataView.isHidden = true

                DispatchQueue.main.async {
                    self?.isShowSearchResult = true
                    if pageNo == 0 {
                        self?.searchCoinsResultList.removeAll()
                    }
                    for symbol:SearchMarketContentStruct in (json?.data)! {
                        self?.searchCoinsResultList.append(symbol)
                    }
                    if self?.searchCoinsResultList.count == 0 {
                        self?.noDataView.isHidden = false
                        self?.mainTab.isHidden = true
                    } else {
                        self?.mainTab.isHidden = false
                        self?.mainTab.reloadData()
                    }
                }
            } else {
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
            }
        }
    }
    //搜索交易对接口
    private func searchExchangePairRequest(keyword: String, pageNo: Int) {
        SearchAPIProvider.request(SearchAPI.searchExchangePair(keyword, pageNo, 5)) { [weak self](result) in
            
            if case let .success(response) = result {
                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(SearchExchangeStruct.self, from: decryptedData)
                if json?.code != 0 {
                    //                    HUD.flash(.labeledError(title: json?.msg , subtitle: nil), delay: 1.0)
                    if json?.msg != nil {
                        self?.noticeOnlyText(json!.msg!)
                    }
                    return
                }
                self?.noDataView.isHidden = true
                
                DispatchQueue.main.async {
                    self?.isShowSearchResult = true
                    self?.searchExchangePairsResultDic = json?.data
                    if self?.searchExchangePairsResultDic?.count == 0 { return }

                        self?.mainTab.reloadData()
                }
            } else {
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
            }
        }
    }
    //保存关键字
    func saveKeywordWithFile(keyword: String) {
        
        var isNeedSave = true
        for title in self.searchHistoryArr {
            
            if (title as! String) == keyword {
                isNeedSave = false
                break
            }
        }
        if isNeedSave {
            if self.searchHistoryArr.contains(keyword) {
                self.searchHistoryArr.replaceObject(at: 0, with: keyword)
            } else {
                self.searchHistoryArr.insert(keyword, at: 0)
            }
            mainTab.reloadData()
            self.searchHistoryArr.write(to: URL.init(fileURLWithPath: self.searchHistoryPath as String), atomically: true)
        }
    }
    @objc private func deleteHistory() {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_DeleteHistorySearch)

        self.searchHistoryArr.removeAllObjects()
        self.searchHistoryArr.write(to: URL.init(fileURLWithPath: self.searchHistoryPath as String), atomically: true)
        mainTab.reloadData()
    }
    //delete search textField
    @objc private func clickDeleteBtn() {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_CancelSearch_MarketsPage)
        self.searchTextField.text = nil
        self.noDataView.isHidden = true
        self.mainTab.isHidden = false
        self.isShowSearchResult = false
        self.mainTab.reloadData()

    }
    //didSelect collectionView Item
    func didSelectItem(symbol: String) {
         self.searchTextField.text = symbol
        self.startSearchCoinAndExchangePairs(keyword: symbol)
        self.saveKeywordWithFile(keyword: symbol)
    }
	//gesture
	@objc private func tap() {
		UIApplication.shared.keyWindow?.endEditing(false)
	}
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var resultText:NSString = NSMutableString.init(string: textField.text!)
        resultText = resultText.replacingCharacters(in: range, with: string) as NSString
        if resultText.length == 0 {
            self.isShowSearchResult = false
            self.mainTab.reloadData()


        } else {
            self.startSearchCoinAndExchangePairs(keyword: resultText as String)
        }
        return true
    }
   
	//textField rerurn
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		guard let searchText = textField.text, textField.text?.count != 0 else {
			return true
		}
        self.startSearchCoinAndExchangePairs(keyword: searchText)
        //add search History
        self.saveKeywordWithFile(keyword: searchText)
		return true
	}
	
	//Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
//        if isShowSearchResult == false {
//            return 2
//        }
        return 2
    }
    
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowSearchResult == false {
            return 1
        } else {
            if section == 0 {
                return searchCoinsResultList.count > 4 ? 4 : searchCoinsResultList.count
            } else {
               return searchExchangePairsResultDic != nil ? 1 : 0
            }
        }

	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if isShowSearchResult {

            if indexPath.section == 0 {
                let cell:MarketsSearchResultCell = tableView.dequeueReusableCell(withIdentifier: "MarketsSearchResultCell") as! MarketsSearchResultCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                let model:SearchMarketContentStruct = searchCoinsResultList[indexPath.item]
                cell.fillDataWithSearchMarketContentStruct(modelContentStruct: model)
                return cell

            } else {
                
                let cell:ExchangeResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ExchangeResultTableViewCell") as! ExchangeResultTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.searchExchangePairsResultDic = searchExchangePairsResultDic
                cell.backgroundColor = mainTab.backgroundColor
                return cell
            }
		}
		
		let cell:MarketsSearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseID) as! MarketsSearchTableViewCell
		cell.delegate = self
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        if indexPath.section == 0 {
            cell.dataArr = currencyRecommendList
        }else{
            cell.dataArr = searchHistoryArr as! Array<String>
        }
		
		return cell
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		if isShowSearchResult {
            if indexPath.section == 1 {
                let num:Int = searchCoinsResultList.count > 4 ? 4 : searchCoinsResultList.count
                let space :CGFloat = searchCoinsResultList.count > 4 ? 35 + 34+8 : 35 + 8
                return SWScreen_height - (SafeAreaTopHeight + 34 + 60 * CGFloat(num) + space)
            }
			return 60
		}
		let cell:MarketsSearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseID) as! MarketsSearchTableViewCell

        if indexPath.section == 0 {
            cell.dataArr = currencyRecommendList
        } else {
            cell.dataArr = searchHistoryArr as! Array<String>
        }
		return cell.mainCollectionView.collectionViewLayout.collectionViewContentSize.height
	}
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  50
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //关键字headerView
        if isShowSearchResult == false {
            let headV:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SWScreen_width, height: 62))
            let title:UILabel = UILabel()
            title.text = section == 0 ? SWLocalizedString(key: "trending") : SWLocalizedString(key: "history_search")
            headV.backgroundColor = mainTab.backgroundColor
            title.font = UIFont.boldSystemFont(ofSize: 12)
            title.textColor = UIColor.init(hexColor: "999999")
            headV.addSubview(title)
            title.snp.makeConstraints { (make) in
                make.leading.equalTo(headV).offset(16)
                make.bottom.equalTo(headV).offset(-15)
            }
            if section == 1 {
                let deleteBtn:UIButton = UIButton()
                deleteBtn.setImage(UIImage.init(named: "markets_delete_gray"), for: UIControlState.normal)
                deleteBtn.addTarget(self, action: #selector(deleteHistory), for: UIControlEvents.touchUpInside)
                headV.addSubview(deleteBtn)
                deleteBtn.snp.makeConstraints({ (make) in
                    make.centerY.equalTo(title)
                    make.trailing.equalTo(headV).offset(-16)
                })
            }
            return headV
            
        } else {
            //搜索结果headerview
            let resultHeader: SearchResultHeaderView = Bundle.main.loadNibNamed("SearchResultHeaderView", owner: self, options: nil)!.first as! SearchResultHeaderView
            resultHeader.titleLabel.text = section == 0 ? SWLocalizedString(key: "coins") : SWLocalizedString(key: "search_exchanges")
            return resultHeader
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 || isShowSearchResult == false {
            return 0
        }
        
        return searchCoinsResultList.count <= 4 ? 8 : 34+8
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 || isShowSearchResult == false {
            return nil
        }
        let footerView:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SWScreen_width, height: 34+8))

        var line_Y : CGFloat = 0
        if searchCoinsResultList.count > 4 {
            line_Y = 34
            footerView.backgroundColor = .white
            let button:UIButton = UIButton.init(type: .custom)
            button.frame = CGRect.init(x: 50, y: 0, width: SWScreen_width-50*2, height: 34)
            button.setTitle(SWLocalizedString(key: "More"), for: .normal)
            button.setTitleColor(UIColor.init(hexColor: "999999"), for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            button.addTarget(self, action: #selector(moreButtonAction), for: .touchUpInside)
            footerView.addSubview(button)
        }
        
        let line: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: line_Y, width: SWScreen_width, height: 8))
        line.backgroundColor = UIColor.init(hexColor: "f2f2f2")
        footerView.addSubview(line)        
        return footerView

    }
	
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isShowSearchResult {
            let model:SearchMarketContentStruct = searchCoinsResultList[indexPath.item]
//            if model.type == "1" {
                let vc:AllDetailViewController = AllDetailViewController()
                vc.symbolName = model.symbol
                vc.symbolIconUrl = model.icon
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
//            } else {
//                let vc:ExchangeDetailViewController = ExchangeDetailViewController()
//                vc.exchangeName = model.symbol
//                vc.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
           
        }
    }
    
    @objc func moreButtonAction() {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_More_SearchResultPage)
        let moreVC:SearchCoinListViewController = SearchCoinListViewController()
        moreVC.searchKey = searchTextField.text
        moreVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(moreVC, animated: true)
    }
	
	deinit {
		print("serachVC deinit")
	}
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchTextField.resignFirstResponder()
    }
}
