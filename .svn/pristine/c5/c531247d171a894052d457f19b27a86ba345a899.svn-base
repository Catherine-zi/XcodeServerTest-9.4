//
//  AllDetailViewController.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/11.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import PKHUD
import AudioToolbox

enum PairSortParamKey: String {
    case vol_asc = "vol_asc"
    case vol_desc = "vol_desc"
    case price_asc = "price_usd_asc"
    case price_desc = "price_usd_desc"
    case change_asc = "price_usd_change_asc"
    case change_desc = "price_usd_change_desc"
}

class AllDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,AAChartLoadFinished {

    var symbolName: String?
    var symbolIconUrl: String?
    var coinModel: MarketsAllDetailDataStruct?
    var pairArray: [MarketsCoinPairDataModel] = []
    var offset = 0
    var limit = 20
    var loading = false
    var noMore = false
    var pairSortingKey = PairSortParamKey.vol_desc.rawValue
    private lazy var pairHeadView : PairHeaderView = {
        let headView : PairHeaderView = Bundle.main.loadNibNamed("PairHeaderView", owner: nil, options: nil)?.last as! PairHeaderView
        headView.frame = CGRect.init(x: 0, y: 0, width: SWScreen_width, height: 34)
        headView.volSortingBtn.addTarget(self, action: #selector(volumnSortingBtnClick(btn:)), for: .touchUpInside)
        headView.changeSortingBtn.addTarget(self, action: #selector(changeSortingBtnClick(btn:)), for: .touchUpInside)
        headView.priceSortingBtn.addTarget(self, action: #selector(priceSortingBtnClick(btn:)), for: .touchUpInside)
        headView.volSortingBtn.isSelected = true
        return headView
    }()

	
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var noDataTipsLabel: UILabel!

	@IBOutlet weak var timesBackView: UIView!
	@IBOutlet weak var loadFailedView: UIView!
	@IBOutlet weak var titleLB: UILabel!
	@IBOutlet weak var backView: UIView!//nav以下视图
    @IBOutlet weak var telegramBtn: UIButton!
    @IBOutlet weak var detailBtn: UIButton!
	@IBOutlet weak var favoriteBtn: UIButton!
	@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderViewWrapper: UIView!
	@IBOutlet weak var topCornerRadiusView: UIView!
	
	//MARK: topView
	private let topCard = UIView()
	private let priceLB = UILabel()
	private let percentLB = UILabel()
	private let marketCapValue = UILabel()
	private let volumeValue = UILabel()
	private var openLB: UILabel!
	private var highLB: UILabel!
	private var lowLB: UILabel!
	private var closeLB: UILabel!
    
	private let tableHeader = UIView()
	
	private lazy var chartV:CoinChartView = {
		
		var chartVFrame = self.loadFailedView.frame
		chartVFrame.size.width = SWScreen_width - 30
		
		let chartV:CoinChartView = CoinChartView.init(frame: (chartVFrame))
		chartV.backgroundColor = self.backView.backgroundColor
		chartV.delegate = self
		self.backView.addSubview(chartV)
		return chartV
	}()
	private lazy var loadingView:SwiftDiyLoading = {
		
		var loadingFrame = self.loadFailedView.frame
		loadingFrame.size.width = SWScreen_width - 30
		
		let loading = SwiftDiyLoading.init(frame: loadingFrame)
		loading.backgroundColor = self.backView.backgroundColor
		self.backView.addSubview(loading)
		return loading;
	}()
	//存储当前的行情趋势
	var marketTrends:[String : [CoinStatusStruct]] = ["1":[],
													 "2":[],
													 "3":[],
													 "4":[],
													 "5":[],
													 "6":[],]
    
	override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_MarketsDetail_Page)
        if symbolName != nil {
            self.networkRequest(symbol: symbolName!)
            self.requestForPairs(offset: self.offset, limit: self.limit, sort: pairSortingKey)
        }
        setUpViews()
//        alertSetTest()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var headerH = self.tableView.bounds.height - 30
//        headerH = headerH > 520 ? headerH : 520
        self.tableHeader.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: headerH)
        
//        self.tableView.tableHeaderView = header
    }

	//MARK: setUpViews
	private func setUpViews() {

		createTopView()
        
        self.tableHeader.backgroundColor = UIColor.clear
        self.tableHeader.addSubview(self.backView)
        self.backView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(self.tableHeader)
        }
        self.tableView.tableHeaderView = self.tableHeader
		
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "MarketPairCell", bundle: nil), forCellReuseIdentifier: "MarketPairCell")
		
		//config bottomBtns
        self.detailBtn.setTitle(SWLocalizedString(key: "coin_detail"), for: .normal)
		self.favoriteBtn.setImage(#imageLiteral(resourceName: "kLine_favorites"), for: UIControlState.selected)
		self.favoriteBtn.setImage(#imageLiteral(resourceName: "kLine_favoritesgrey"), for: UIControlState.normal)
		self.favoriteBtn.setTitle(SWLocalizedString(key: "favorite"), for: UIControlState.normal)
//        self.favoriteBtn.setTitle(SWLocalizedString(key: "cancel_favorite"), for: UIControlState.selected)
        if let teleW = self.telegramBtn.titleLabel?.sizeThatFits(CGSize.zero).width,
			let teleH = self.telegramBtn.titleLabel?.sizeThatFits(CGSize.zero).height,
            let imgW = self.telegramBtn.imageView?.bounds.width,
			let imgH = self.telegramBtn.imageView?.bounds.height{
			self.telegramBtn.titleEdgeInsets = UIEdgeInsetsMake(imgH + 5, -(imgW), 0,0);
			self.telegramBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, teleH + 5, -(teleW));
        }
        self.telegramBtn.setImage(#imageLiteral(resourceName: "iconchatgrey"), for: .selected)
        self.telegramBtn.setTitleColor(UIColor.init(hexColor: "dddddd"), for: .selected)
		if let detW = self.detailBtn.titleLabel?.sizeThatFits(CGSize.zero).width,
			let detH = self.detailBtn.titleLabel?.sizeThatFits(CGSize.zero).height,
			let imgW = self.detailBtn.imageView?.bounds.width,
		let imgH = self.detailBtn.imageView?.bounds.height{
			self.detailBtn.titleEdgeInsets = UIEdgeInsetsMake(imgH + 5, -(imgW), 0,0);
			self.detailBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, detH + 5, -(detW));
		}
		let tempLB = UILabel()
		tempLB.text = self.favoriteBtn.titleLabel?.text
		tempLB.font = UIFont.boldSystemFont(ofSize: 9)
		tempLB.sizeToFit()
		self.favoriteBtn.titleEdgeInsets = UIEdgeInsetsMake(#imageLiteral(resourceName: "kLine_favorites").size.height + 5, -( #imageLiteral(resourceName: "kLine_favorites").size.width), 0,0);
		self.favoriteBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, tempLB.bounds.size.height + 5, -(tempLB.bounds.size.width));

		if let symbolNameStr = self.symbolName {
			self.navTitleLabel.text = String(symbolNameStr).appending("(").appending(SWLocalizedString(key: "average")).appending(")")
		}
		//曲线图 时间按钮
		timesBackView.backgroundColor = timesBackView.superview?.backgroundColor
		let arr:Array<String> = [SWLocalizedString(key: "hour"), SWLocalizedString(key: "day"), SWLocalizedString(key: "week"),SWLocalizedString(key: "month"),SWLocalizedString(key: "year"),SWLocalizedString(key: "lft")]

		var flag:Int = 0
		let btnW:CGFloat = SWScreen_width == 320.0 ? 45 : 50
		let btnH:CGFloat = 30
		let padding:CGFloat = 15
		var btnX:CGFloat = padding
		let btnY:CGFloat = 0
		let margin:CGFloat = (SWScreen_width - btnW * CGFloat(arr.count) - padding * 2)/CGFloat(arr.count - 1)
		for title in arr {
			let btn:AllDetailDiyButton = AllDetailDiyButton()
			btn.setTitle(title, for: .normal)
			btn.tag = flag
			btn.isSelected = flag == 1 ? true : false
			btn.addTarget(self, action: #selector(didClickTimeBtn(sender:)), for: .touchUpInside)
			if flag == 1 {
				didClickTimeBtn(sender: btn)
			}
			flag = flag + 1
			btn.frame = CGRect.init(x: btnX, y: btnY, width: btnW, height: btnH)
			btnX = padding + ((btnW + margin) * CGFloat(flag))
			timesBackView.addSubview(btn)
		}
		
		//load failed view
		loadFailedView.backgroundColor = loadFailedView.superview?.backgroundColor
		noDataTipsLabel.text = SWLocalizedString(key: "no_chart_data_available")
		
		chartV.snp.makeConstraints { (make) in
			make.edges.equalTo(self.loadFailedView)
		}
		loadingView.snp.makeConstraints { (make) in
			make.edges.equalTo(self.loadFailedView)
		}
	}
	private func createTopView() {
		
		let padding:CGFloat = 15
		//top
		topCard.backgroundColor = UIColor.white
		topCard.layer.cornerRadius = 4
		topCard.layer.shadowRadius = 4
		topCard.layer.shadowColor = UIColor.init(hexColor: "EBEBEB").cgColor
		topCard.layer.shadowOffset = CGSize(width: 0, height: 5)
		topCard.layer.shadowOpacity = 0.7
		topCard.layer.masksToBounds = false
		topCard.frame = CGRect(x: 0, y: 0, width: SWScreen_width - padding * 2 , height: 150)
		topCornerRadiusView.addSubview(topCard)
		
		let bottomView = UIView()
		topCard.addSubview(bottomView)
		bottomView.snp.makeConstraints { (make) in
			make.bottom.equalTo(topCard)
			make.width.equalTo(topCard)
			make.centerX.equalTo(topCard)
			make.height.equalTo(60)
		}
		let arr:Array<String> = [SWLocalizedString(key: "open"),
								 SWLocalizedString(key: "high"),
								 SWLocalizedString(key: "low"),
								 SWLocalizedString(key: "close_price")]
		var flag:Int = 0
		let width:CGFloat = (SWScreen_width - padding * 2) / CGFloat(arr.count)
		for title in arr {
			let view = UIView()
			bottomView.addSubview(view)
			view.frame = CGRect(x: width * CGFloat(flag), y: 0, width: width, height: 60)
			flag = flag + 1
			let titleLB = UILabel()
			titleLB.text = title
			titleLB.textColor = UIColor.init(hexColor: "BBBBBB")
			titleLB.font = UIFont.systemFont(ofSize: 10)
			
			let valueLB = UILabel()
			valueLB.textColor = UIColor.init(hexColor: "356AF6")
			valueLB.font = UIFont.boldSystemFont(ofSize: 12)
			valueLB.text = "--"
			
			let line = UIView()
			line.backgroundColor = UIColor.init(hexColor: "F2F2F2")
			view.addSubview(titleLB)
			view.addSubview(valueLB)
			view.addSubview(line)
			
			titleLB.snp.makeConstraints { (make) in
				make.centerX.equalTo(view)
				make.top.equalTo(view).offset(15)
			}
			valueLB.snp.makeConstraints { (make) in
				make.centerX.equalTo(view)
				make.top.equalTo(titleLB.snp.bottom).offset(2)
			}
			line.snp.makeConstraints { (make) in
				make.centerY.equalTo(view)
				make.width.equalTo(1)
				make.right.equalTo(view)
				make.height.equalTo(15)
			}
			switch flag {
			case 1:
				openLB = valueLB
				line.isHidden = false
			case 2:
				highLB = valueLB
				line.isHidden = false
			case 3:
				lowLB = valueLB
				line.isHidden = false
			case 4:
				closeLB = valueLB
				line.isHidden = true
			default:
				print("")
			}
		}
		
		//line
		let line = UIView()
		line.backgroundColor = UIColor.init(hexColor: "F2F2F2")
		topCard.addSubview(line)
		line.snp.makeConstraints { (make) in
			make.left.right.equalTo(topCard)
			make.bottom.equalTo(bottomView.snp.top)
			make.height.equalTo(1)
		}
		//top
		let topView = UIView()
		topCard.addSubview(topView)
		topView.snp.makeConstraints { (make) in
			make.left.right.top.equalTo(topCard)
			make.bottom.equalTo(bottomView.snp.top)
		}
		
		priceLB.textColor = UIColor.init(hexColor: "F96C6C")
		priceLB.font = UIFont.boldSystemFont(ofSize: 24)
		priceLB.text = "--"
		
		percentLB.textColor = UIColor.white
		percentLB.font = UIFont.boldSystemFont(ofSize: 15)
		percentLB.backgroundColor = UIColor.init(hexColor: "F96C6C")
		percentLB.layer.cornerRadius = 4.0
		percentLB.layer.masksToBounds = true
		percentLB.text = " -- "
		
		let marketCap = UILabel()
		marketCap.text = SWLocalizedString(key: "market_cap").uppercased()
		marketCap.textColor = UIColor.init(hexColor: "BBBBBB")
		marketCap.font = UIFont.systemFont(ofSize: 10)
		
		let volume = UILabel()
		volume.text = SWLocalizedString(key: "volume_24h").uppercased()
		volume.textColor = UIColor.init(hexColor: "BBBBBB")
		volume.font = UIFont.systemFont(ofSize: 10)
		
		marketCapValue.textColor = UIColor.init(hexColor: "333333")
		marketCapValue.font = UIFont.boldSystemFont(ofSize: 10)
		marketCapValue.text = "--"
		
		volumeValue.textColor = UIColor.init(hexColor: "333333")
		volumeValue.font = UIFont.boldSystemFont(ofSize: 10)
		volumeValue.text = "--"
		
		topView.addSubview(priceLB)
		topView.addSubview(percentLB)
		topView.addSubview(marketCap)
		topView.addSubview(marketCapValue)
		topView.addSubview(volume)
		topView.addSubview(volumeValue)
		
		priceLB.snp.makeConstraints { (make) in
			make.left.equalTo(topView).offset(15)
			make.top.equalTo(topView).offset(18)
			//			make.right.equalTo(percentLB.snp.left)
		}
		percentLB.snp.makeConstraints { (make) in
			make.right.equalTo(topView).offset(-15)
			make.centerY.equalTo(priceLB)
			make.height.equalTo(27)
		}
		volume.snp.makeConstraints { (make) in
			make.left.equalTo(priceLB)
			make.bottom.equalTo(topView).offset(-8)
		}
		marketCap.snp.makeConstraints { (make) in
			make.left.equalTo(volume)
			make.bottom.equalTo(volume.snp.top).offset(-2)
		}
		marketCapValue.snp.makeConstraints { (make) in
			make.centerY.equalTo(marketCap)
			make.left.equalTo(marketCap.snp.right).offset(6)
		}
		volumeValue.snp.makeConstraints { (make) in
			make.centerY.equalTo(volume)
			make.left.equalTo(volume.snp.right).offset(6)
		}
	}
    private func updateTableViewHeaderViewHeight() {
        // Add where so we don't keep calling this if the heights are the same
        if let tableHeaderView = self.tableView.tableHeaderView, self.tableHeaderViewWrapper.frame.height != tableHeaderView.frame.height {
            // Grab the frame out of tableHeaderView
            var headerViewFrame = tableHeaderView.frame
            
            // Set the headerViewFrame's height to be the wrapper's height,
            // dynamically calculated using constraints
            headerViewFrame.size.height =
                self.tableHeaderViewWrapper.frame.size.height
            headerViewFrame.origin.y = 0
            
            // Assign the frame of the tableHeaderView to be the
            // headerViewFrame we created above with its updated height
            tableHeaderView.frame = headerViewFrame
            
            // Apply these changes in the next run loop iteration
//            dispatch_get_main_queue().async() {
//                UIView.beginAnimations("tableHeaderView", context: nil);
                self.tableView.tableHeaderView = self.tableView.tableHeaderView;
//                UIView.commitAnimations()
//            }
        }
    }
	
	//MARK: loadData
    func networkRequest(symbol: String) {

//        HUD.show(HUDContentType.progress)
        MarketsAPIProvider.request(MarketsAPI.markets_allDetail(symbol)) { [weak self](result) in

            if case let .success(response) = result {
                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(MarketsAllDetailStruct.self, from: decryptedData)
                if json?.code != 0 {
                    return
                }
                var symbol:MarketsAllDetailDataStruct = MarketsAllDetailDataStruct()
                if json?.data != nil {
                    symbol = (json?.data)!
                }
                
                self?.coinModel = symbol

				if let chatStr = symbol.chat,!chatStr.isEmpty {
					self?.telegramBtn.isSelected = false
				}else {
					self?.telegramBtn.isSelected = true
				}
				if let priceUsd = symbol.priceUsd,let decimal:Decimal = Decimal(string: priceUsd) {

                    self?.priceLB.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: decimal, inDollar: true, short: false)
				}
                let favoriteBtnState = symbol.favoriteStatus == 1 ? SWUEC_Show_CancelFavorites_MarketsDetail_Page : SWUEC_Show_AddFavorites_MarketsDetail_Page
                SPUserEventsManager.shared.addCount(forEvent: favoriteBtnState)
                
				self?.favoriteBtn.isSelected = symbol.favoriteStatus == 1 ? true : false
				let tempLB = UILabel()
				tempLB.text = self?.favoriteBtn.titleLabel?.text
				tempLB.font = UIFont.boldSystemFont(ofSize: 9)
				tempLB.sizeToFit()
				// button标题的偏移量
				self?.favoriteBtn.titleEdgeInsets = UIEdgeInsetsMake(#imageLiteral(resourceName: "kLine_favorites").size.height + 5, -( #imageLiteral(resourceName: "kLine_favorites").size.width), 0,0);
				// button图片的偏移量
				self?.favoriteBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, tempLB.bounds.size.height + 5, -(tempLB.bounds.size.width));
				
				if let perCStr = symbol.percentChange24h ,let percentChange = Float(perCStr){
					
					self?.percentLB.text = percentChange < Float(0) ? (" " + perCStr.appending("% ")) : " +".appending(perCStr).appending("% ")
					self?.percentLB.backgroundColor = percentChange < Float(0) ? GainsDownColor : GainsUpColor
				}
				
				if let openPriceUsd = symbol.openPriceUsd,let decimal:Decimal = Decimal(string: openPriceUsd){
                    self?.openLB.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: decimal, inDollar: true, short: false)
				}
				if let highPriceUsd = symbol.highPriceUsd,let decimal = Decimal(string: highPriceUsd){
                    self?.highLB.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: decimal, inDollar: true, short: false)
				}
				if let lowPriceUsd = symbol.lowPriceUsd,let decimal = Decimal(string: lowPriceUsd){
                    self?.lowLB.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: decimal, inDollar: true, short: false)
				}
				if let closePriceUsd = symbol.closePriceUsd,let decimal = Decimal(string: closePriceUsd){
                    self?.closeLB.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: decimal, inDollar: true, short: false)
				}
				if let marketCapUsd = symbol.marketCapUsd,let decimal = Decimal(string: marketCapUsd){
                    self?.marketCapValue.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: decimal, inDollar: true, short: false)
				}
				if let volumeUsd = symbol.volumeUsd,let decimal = Decimal(string: volumeUsd){
                    self?.volumeValue.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: decimal, inDollar: true, short: false)
				}

            } else {
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
            }
        }
    }
    
    private func requestForPairs(offset: Int, limit: Int, sort: String) {
        guard let symbol = self.symbolName else {
            return
        }
        self.loading = true
        MarketsAPIProvider.request(MarketsAPI.markets_coinPair(symbol, offset, limit, sort)) { [weak self] (result) in
            self?.loading = false
            switch result {
            case let .success(response):
                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(MarketsCoinPairModel.self, from: decryptedData)
                if json?.code != 0 {
                    print("get pair error")
                    return
                }
                if let pairs = json?.data {
                    if pairs.count == 0 {
                        self?.noMore = true
                    }
                    if self?.offset == 0 {
						SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_CoinExchange_MarketsDetail_Page)
                        self?.pairArray.removeAll()
                    }
                    self?.pairArray += pairs
                    if let limit = self?.limit {
                        // limit bug
                        self?.offset += limit
                    }
                    self?.tableView.reloadData()
                }
            case let .failure(error):
                print("get pair error: \(error)")
            }
        }
    }
	
	//MARK: TableViewDelegate & Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pairArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.pairHeadView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.pairArray.count == 0 {
            return 0
        }
        return 34
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MarketPairCell", for: indexPath) as? MarketPairCell {
            if indexPath.row < self.pairArray.count {
                cell.setContent(model: self.pairArray[indexPath.row], indexPath: indexPath)
                cell.titleLbl.text = self.pairArray[indexPath.row].exchange
            }
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = UIColor.white
            } else {
                cell.backgroundColor = UIColor.init(hexColor: "f2f2f2")
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
		
		let vc:TransactionPairDetailViewController = TransactionPairDetailViewController()
		let symbol:MarketsCoinPairDataModel = self.pairArray[indexPath.row]
		vc.coinPair = symbol
		vc.reloadFavoriteStatusClosure = { (status:Int) in
			print("\(status)")
			var symbol = self.pairArray[indexPath.row]
			symbol.favorite_status = status
			self.pairArray[indexPath.row] = symbol
			tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
		}
		
		vc.hidesBottomBarWhenPushed = true
		self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.pairArray.count - 3,
            !self.loading,
            !self.noMore {
            self.requestForPairs(offset: self.offset, limit: self.limit, sort: self.pairSortingKey)
        }
    }
	
	//MARK: functions
    @objc private func volumnSortingBtnClick(btn: SortButton) {
        if self.loading == true { return }
        self.tableView.setContentOffset(CGPoint.init(x: 0, y: self.backView.frame.height), animated: true)
        self.setSortingTypeAndButton(clickBtn: btn)
        let sortingKey = btn.isAsc == true ? PairSortParamKey.vol_asc.rawValue : PairSortParamKey.vol_desc.rawValue
        pairSortingKey = sortingKey
        self.offset = 0
        self.noMore = false
        self.requestForPairs(offset: self.offset, limit: self.limit, sort: pairSortingKey)
    }
    
    @objc private func changeSortingBtnClick(btn: SortButton) {
        if self.loading == true { return }
        self.tableView.setContentOffset(CGPoint.init(x: 0, y: self.backView.frame.height), animated: true)
        self.setSortingTypeAndButton(clickBtn: btn)
        let sortingKey = btn.isAsc == true ? PairSortParamKey.change_asc.rawValue : PairSortParamKey.change_desc.rawValue
        pairSortingKey = sortingKey
        self.offset = 0
        self.noMore = false
        self.requestForPairs(offset: self.offset, limit: self.limit, sort: pairSortingKey)
    }
    
    @objc private func priceSortingBtnClick(btn: SortButton) {
        if self.loading == true { return }
        self.tableView.setContentOffset(CGPoint.init(x: 0, y: self.backView.frame.height), animated: true)
        self.setSortingTypeAndButton(clickBtn: btn)
        let sortingKey = btn.isAsc == true ? PairSortParamKey.price_asc.rawValue : PairSortParamKey.price_desc.rawValue
        pairSortingKey = sortingKey
        self.offset = 0
        self.noMore = false
        self.requestForPairs(offset: self.offset, limit: self.limit, sort: pairSortingKey)
    }
    
    private func setSortingTypeAndButton(clickBtn: SortButton) {
        for btn in pairHeadView.sortBtnArray {
            if btn == clickBtn {
                if btn.isSelected {
                    btn.isAsc = !btn.isAsc
                } else {
                    btn.isAsc = false
                    btn.isSelected = true
                }
            } else {
                btn.isSelected = false
            }
        }
    }
	
	//MARK: 点击Tag，切换趋势图
	@objc private func didClickTimeBtn(sender:AllDetailDiyButton) {
		
		for subView in timesBackView.subviews  {
			
			if subView.isKind(of: AllDetailDiyButton.classForCoder()) {
				let btn:AllDetailDiyButton = subView as! AllDetailDiyButton
				btn.isSelected = btn.tag == sender.tag ? true : false
			}
		}
		print("\(String(describing: sender.titleLabel?.text))")
		
		let typeStr = String(sender.tag + 1)
		
		let date = Date()
		let timeEnd:NSInteger = NSInteger(date.timeIntervalSince1970)
		var timeBegin:NSInteger = 0
		var userEventStr:String = ""
		switch typeStr {
		case "1":
			timeBegin = timeEnd - 60 * 60
			userEventStr = SWUEC_Click_OneHour
		case "2":
			timeBegin = timeEnd - 60 * 60 * 24
			userEventStr = SWUEC_Click_OneDay
		case "3":
			timeBegin = timeEnd - 60 * 60 * 24 * 7
			userEventStr = SWUEC_Click_OneWeek
		case "4":
			timeBegin = timeEnd - 60 * 60 * 24 * 30
			userEventStr = SWUEC_Click_OneMonth
		case "5":
			timeBegin = timeEnd - 60 * 60 * 24 * 30 * 12
			userEventStr = SWUEC_Click_OneYear
		case "6":
			timeBegin = timeEnd - 60 * 60
			userEventStr = SWUEC_Click_LifeTime
		default:
			timeBegin = timeEnd - 60 * 60 * 24 * 12
		}
		SPUserEventsManager.shared.addCount(forEvent: userEventStr)

		self.loadFailedView.isHidden = true
		self.chartV.isHidden = true
		self.loadingView.isHidden = false
		self.loadingView.startLoading()
		
		MarketsAPIProvider.request(MarketsAPI.markets_trend((self.symbolName ?? ""), String(timeBegin), String(timeEnd), typeStr)) { [weak self](result) in
			
			guard let strongSelf = self else{
				return
			}
			
			if case let .success(response) = result {
				let decryptedData = Data.init(decryptionResponseData: response.data)
				let json = try? JSONDecoder().decode(MarketTrendStruct.self, from: decryptedData)
				
					if json == nil {
						strongSelf.chartFinishedLoad()
						strongSelf.loadFailedView.isHidden = false
//						strongSelf.loadFailedView.superview?.bringSubview(toFront: (strongSelf.loadFailedView)!)
						return
					}
					if json?.code != 0 {
						strongSelf.chartFinishedLoad()
						strongSelf.loadFailedView.isHidden = false
//						strongSelf.loadFailedView.superview?.bringSubview(toFront: (strongSelf.loadFailedView)!)
						return
					}
					if let count = json?.data?.count,
						count > 0
					{
						strongSelf.marketTrends[typeStr] = json?.data
						DispatchQueue.main.async {
							
							strongSelf.chartV.isHidden = false
							strongSelf.chartV.addOptions(json?.data, timeType: sender.tag, isBTC: (self?.symbolName == "BTC") ? true : false)
						}
					} else {
						strongSelf.chartFinishedLoad()
						strongSelf.loadFailedView.isHidden = false
//						strongSelf.loadFailedView.superview?.bringSubview(toFront: (strongSelf.loadFailedView))
						
						return
					}
				

			}else {
					strongSelf.chartFinishedLoad()
					strongSelf.loadFailedView.isHidden = false
					strongSelf.noticeOnlyText(SWLocalizedString(key: "network_error"))
				
				
			}
			
		}
		
	}
	func chartFinishedLoad() {
		self.loadingView.stopLoading()
		self.loadingView.isHidden = true
	}
	@IBAction func clickFavoritesbtn(_ sender: UIButton) {
        let clickBtnState = sender.isSelected ? SWUEC_Click_CancelFavorites_MarketsDetail_Page : SWUEC_Click_AddFavorites_MarketsDetail_Page
        SPUserEventsManager.shared.addCount(forEvent: clickBtnState)
        
        
		sender.isSelected = !sender.isSelected
		
//        let tempLB = UILabel()
		if sender.isSelected {
//            tempLB.text = SWLocalizedString(key: "cancel_favorite")
			SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_AddFavorites_PairsDetail_Page)
		}else {
//            tempLB.text = SWLocalizedString(key: "favorite")
			SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_CancelFavorites_PairsDetail_Page)
		}
//        tempLB.font = UIFont.boldSystemFont(ofSize: 9)
//        tempLB.sizeToFit()
//        sender.imageEdgeInsets = UIEdgeInsetsMake(0, 0, tempLB.bounds.size.height + 5, -(tempLB.bounds.size.width));
        
        self.favoritesRequest(symbol: self.symbolName!, exchange: "",pair: "", isFavorite: sender.isSelected)
	}
    @IBAction func telegramTapped(_ sender: Any) {
		SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Telegram_MarketsDetail_Page)
        if self.telegramBtn.isSelected == true {
            self.noticeOnlyText(SWLocalizedString(key: "no_tg_group"))
            return
        }
		self.tabBarController?.selectedIndex = 1
		
		if TelegramUserInfo.shareInstance.telegramLoginState == "yes",let link = self.coinModel?.chat {
			
			SWTabBarController.gotoChannel(link)
		}
    }
    @IBAction func detailTapped(_ sender: Any) {
		SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Details_MarketsDetail_Page)
        let detailVC = CoinDetailViewController()
        detailVC.coinModel = coinModel
        detailVC.symbol = symbolName
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_MarketsDetail_Page)
		self.navigationController?.popViewController(animated: true)
	}
    
    func favoritesRequest(symbol: String, exchange: String, pair: String, isFavorite: Bool) {
        if symbol.count == 0 {
            print("symbol error")
            return
        }
        MarketsAPIProvider.request(MarketsAPI.markets_currencyFavorite(symbol, exchange, pair, isFavorite)) { (result) in
            if case let .success(response) = result {
                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(SimpleStruct.self, from: decryptedData)
                if json?.code != 0 {
//                    print("currencyFavorite response json: \(String(describing: json ?? nil))")
                    return
                }
				DispatchQueue.main.async {
					let msg: String = isFavorite == false ?  SWLocalizedString(key: "cancel_success") :  SWLocalizedString(key: "add_success")
					self.noticeOnlyText(msg)
				}

            } else {
                self.noticeOnlyText(SWLocalizedString(key: "network_error"))
            }
        }
    }
    
    func alertSetTest() {
        AlertAPIProvider.request(AlertAPI.alert_set(exchange: "Binance", pair: "ETH/USDT", above_change: "4", above_price: "200", below_change: "4", below_price: "300", id: nil)) { (result) in
            switch result {
            case let .success(response):
                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(AlertSetDeleteModel.self, from: decryptedData)
                if json?.code != 0 {
                    print("alert_set error: \(String(describing: json ?? nil))")
                    return
                }
            case let .failure(error):
                print(error)
            }
        }
//        AlertAPIProvider.request(AlertAPI.alert_set_list(limit: 20, offset: 0)) { (result) in
//            switch result {
//            case let .success(response):
//                let decryptedData = Data.init(decryptionResponseData: response.data)
//                let json = try? JSONDecoder().decode(AlertSetListModel.self, from: decryptedData)
//                if json?.code != 0 {
//                    print("alert_set error: \(String(describing: json ?? nil))")
//                    return
//                }
//            case let .failure(error):
//                print(error)
//            }
//        }
//        AlertAPIProvider.request(AlertAPI.alert_msg_history(limit: 20, offset: 0)) { (result) in
//            switch result {
//            case let .success(response):
//                let decryptedData = Data.init(decryptionResponseData: response.data)
//                let json = try? JSONDecoder().decode(AlertMsgHistoryModel.self, from: decryptedData)
//                if json?.code != 0 {
//                    print("alert_set error: \(String(describing: json ?? nil))")
//                    return
//                }
//            case let .failure(error):
//                print(error)
//            }
//        }
    }
	
	deinit {
		print("\(self.classForCoder) deinit")
	}
}
