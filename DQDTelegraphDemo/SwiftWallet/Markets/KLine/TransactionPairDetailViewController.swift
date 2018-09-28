//
//  TransactionPairDetailViewController.swift
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/7/31.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit
import Starscream
class TransactionPairDetailViewController: BaseNavViewController,WebSocketDelegate {
	
	//MARK: WebSocketDelegate
	func websocketDidConnect(socket: WebSocketClient) {
		print("DidConnnect")
	}
	
	func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
		print("DidDisconnect")
	}
	
	func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
		print("text = \(text)")
		
		if text.isEmpty {
			return
		}
		guard let data = text.data(using: String.Encoding.utf8) else {
			return
		}
		
		
		guard let json = try? JSONDecoder().decode(WebSocketPairStruct.self, from: data) else {
			return
		}

		guard let change = json.price24hChange,let price = json.priceUsd else {
			return
		}
		
		if let percentChange = Float(change){
			
			percentLB.text = " " + (percentChange < Float(0) ? change.appending("%") : "+".appending(change).appending("%")) + " "
			percentLB.backgroundColor = percentChange < Float(0) ? GainsDownColor : GainsUpColor
		}
		if let decimal:Decimal = Decimal(string: String(price)) {
			
			priceLB.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: decimal, inDollar: true, short: false)
		}
		
		guard let rightPrice = json.pairRightPrice else {
			return
		}
		if let rightPriceF = Double(rightPrice) {
			if rightPriceF != 0 {//防止后台为空
				
				if let decimal:Decimal = Decimal(string: rightPrice) {
					pairRightPriceValue.text = "=" + decimal.description + " " + self.pairRightStr
				}
				
			}
		}
		priceLB.textColor = percentLB.backgroundColor
		pairRightPriceValue.textColor = percentLB.backgroundColor
		
	}
	
	func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
		print("data = \(data)")
	}
	

	
	var coinPair: MarketsCoinPairDataModel?
	var transactionPairTitle:String!
	var exchangeName:String!
	var pairRightStr:String! = " "//pair 右边字段
	
	var reloadFavoriteStatusClosure: ((Int) -> Void)!//用于刷新 是否收藏的数据源
	
	private let scrollView = UIScrollView()
	
	private let topCard = UIView()
	private let bottomView = UIView()
	let bottomCoinImageV = UIImageView()
    
    let coinBtn = UIButton()

	private let priceLB = UILabel()
	private let percentLB = UILabel()
	private let pairRightPriceValue = UILabel()
	private let volumeValue = UILabel()
	private var openLB: UILabel!
	private var highLB: UILabel!
	private var lowLB: UILabel!
	private var closeLB: UILabel!
	
	private let bottomViewH:CGFloat = 50
	private let topCardH:CGFloat = 150
	private let topCardMargin:CGFloat = 10
	
	private var socket:WebSocket!
	private let timer = RepeatingTimer(timeInterval: 25)
	
	private var isLoadingFavorite:Bool = false
	
	//MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

		//setmodel
		if let coinPairStr = coinPair?.pair, let exchange = coinPair?.exchange {
			self.navTitle.text = coinPairStr + "(" + exchange + ")"
			
			if let rightStr = coinPairStr.components(separatedBy: "/").last {
				self.pairRightStr = rightStr
			}
		}
		
		self.transactionPairTitle = coinPair?.pair ?? ""
		self.exchangeName = coinPair?.exchange ?? ""
		
		setUpViews()
		
		addSocket()
		
		//loadData
		loadData()
		
		SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_PairsDetail_Page)
    }

	private func setUpViews() {
		
		contentView.backgroundColor = UIColor.white
		
		scrollView.backgroundColor = UIColor.init(hexColor: "F2F2F2")
		contentView.addSubview(scrollView)
		scrollView.snp.makeConstraints { (make) in
			make.top.left.right.equalTo(contentView)
			make.bottom.equalTo(contentView).offset(-(bottomViewH + ((SWScreen_height == iPhoneXScreenHeight) ? iPhoneXBottomHeight : 0)))
		}
		//top
		createTopView()
		
		//bottom btn
		createBottomView()
		
		//计算contentSize
		var kLineH = SWScreen_height - topCard.frame.maxY - 50 - 45 * 2 - topCardMargin - SWNavBarHeight - SWStatusBarH - ((SWScreen_height == iPhoneXScreenHeight) ? iPhoneXBottomHeight : 0)
		kLineH = (kLineH > 240 ? kLineH : 240)
		
		let contentSizeH: CGFloat = kLineH + topCardH + topCardMargin + 45 * 2
		scrollView.contentSize = CGSize(width: contentView.bounds.size.width, height: contentSizeH)
		
		//kLine
		let kLine = KLineView.init(frame: CGRect(x: 0, y: 45 + topCard.frame.maxY, width: SWScreen_width, height: kLineH), isFullScreen: false, exchangeName: exchangeName, transactionPairTitle: transactionPairTitle,klineType: .kLineForDay,currentTimeType: "1h")

		kLine.backgroundColor = scrollView.backgroundColor
		scrollView.addSubview(kLine)
//		kLine.exchangeName = exchangeName
//		kLine.transactionPairTitle = transactionPairTitle
		
	}

	private func loadData() {
		guard let exchangeName = coinPair?.exchange,let pair = coinPair?.pair else {
			return
		}
		MarketsAPIProvider.request(MarketsAPI.markets_exchangePairTicket(exchangeName, pair)) { [weak self](result) in
			
			guard let strongSelf = self else{
				return
			}
			
			if case let .success(response) = result {
				
				let decryptedData = Data.init(decryptionResponseData: response.data)
				let json = try? JSONDecoder().decode(ExchangePairTicketStruct.self, from: decryptedData)
				
				DispatchQueue.main.async(execute: {
		
					
					if let perCStr = json?.data?.priceChangeUsd24h ,let percentChange = Float(perCStr){
						
						strongSelf.percentLB.text = " " + (percentChange < Float(0) ? perCStr.appending("%") : "+".appending(perCStr).appending("%")) + " "
						strongSelf.percentLB.backgroundColor = percentChange < Float(0) ? GainsDownColor : GainsUpColor
					}
					if let priceUsd = json?.data?.priceUsd,let decimal:Decimal = Decimal(string: priceUsd) {
						
						strongSelf.priceLB.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: decimal, inDollar: true, short: false)
						strongSelf.priceLB.textColor = strongSelf.percentLB.backgroundColor
					}
					if let pairRightPriceUsd = json?.data?.pairRightPrice, let decimal:Decimal = Decimal(string: pairRightPriceUsd) {
						strongSelf.pairRightPriceValue.text = "=" + decimal.description + " " + strongSelf.pairRightStr
						strongSelf.pairRightPriceValue.textColor = strongSelf.percentLB.backgroundColor
					}
					if let volumeUsd = json?.data?.volume24h,let decimal = Decimal(string: volumeUsd){
						strongSelf.volumeValue.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: decimal, inDollar: true, short: false)
					}
					
					
					if let openPriceUsd = json?.data?.openPrice,let decimal:Decimal = Decimal(string: openPriceUsd){
						strongSelf.openLB.text = decimal.description//SwiftExchanger.shared.getFormattedCurrencyString(amount: decimal, inDollar: true, short: false)
					}
					if let highPriceUsd = json?.data?.heightPrice,let decimal = Decimal(string: highPriceUsd){
						strongSelf.highLB.text = decimal.description//SwiftExchanger.shared.getFormattedCurrencyString(amount: decimal, inDollar: true, short: false)
					}
					if let lowPriceUsd = json?.data?.lowPrice,let decimal = Decimal(string: lowPriceUsd){
						strongSelf.lowLB.text = decimal.description//SwiftExchanger.shared.getFormattedCurrencyString(amount: decimal, inDollar: true, short: false)
					}
					if let closePriceUsd = json?.data?.closePrice,let decimal = Decimal(string: closePriceUsd){
						strongSelf.closeLB.text = decimal.description//SwiftExchanger.shared.getFormattedCurrencyString(amount: decimal, inDollar: true, short: false)
					}
					strongSelf.bottomCoinImageV.coinImageSet(urlStr: json?.data?.icon)
					strongSelf.coinBtn.setImage(strongSelf.bottomCoinImageV.image, for: .normal)
				})
			}else {
				
			}
		}
	}
	
	private func addSocket() {
		
		guard let exc = coinPair?.exchange,var pair = coinPair?.pair else {
			return
		}
		pair = pair.replacingOccurrences(of: "/", with: "_")
		let appendStr =  exc + "@" + pair
//		let schemeUrl = "ws://stream.web.cryptohubapp.info:9501/ws/"
		//add socket
		guard let url = URL(string: websocketUrl + appendStr) else {
			return
		}
		socket = WebSocket(url: url)
		socket.delegate = self
		socket.connect()
		
		timer.eventHandler = {[weak self] in
			
			self?.socket.write(string: "{ping: + \(Date().timeIntervalSince1970) + }"  )
		}
		timer.resume()
		
	}
    
    @objc func alertBtnAction(button: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Alert_PairsDetail_Page)
        let alertVC = ExchangeAddAlertViewController()
        alertVC.exchangeName = coinPair?.exchange ?? ""
        alertVC.pairName = coinPair?.pair ?? ""
        if let priceStr = coinPair?.pair_right_price,
            let price = Decimal(string: priceStr)
        {
            alertVC.currentPrice = price
        }
        self.navigationController?.pushViewController(alertVC, animated: true)
    }
    
	@objc func didClickFavorite(sender:UIButton) {
		
		guard let symbol = coinPair?.symbol,
			let exchange = coinPair?.exchange,
			let pair = coinPair?.pair else {
				return
		}
		
		if isLoadingFavorite {
			return
		}
		isLoadingFavorite = true
		let isFavorite = sender.isSelected ? false : true
		
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
		
		if isFavorite {
			self.noticeOnlyText(SWLocalizedString(key: "add_success"))
		}else {
			self.noticeOnlyText(SWLocalizedString(key: "cancel_success"))
		}
		
		MarketsAPIProvider.request(MarketsAPI.markets_currencyFavorite(symbol,exchange,pair,isFavorite)) {[weak self](result) in
			
			guard let strongSelf = self else {
				return
			}
			strongSelf.isLoadingFavorite = false
			if case let .success(response) = result {
				
				let decryptedData = Data.init(decryptionResponseData: response.data)
				let json = try? JSONDecoder().decode(SimpleStruct.self, from: decryptedData)
				
				if json?.code != 0 {
					if isFavorite {
						strongSelf.noticeOnlyText(SWLocalizedString(key: "add_failure"))
					}else {
						strongSelf.noticeOnlyText(SWLocalizedString(key: "cancel_failure"))
					}
					sender.isSelected = !sender.isSelected
					
					return
				}
				
				if (strongSelf.reloadFavoriteStatusClosure != nil) {
					strongSelf.reloadFavoriteStatusClosure(sender.isSelected ? 1 : 0)
				}
			
			}else {
				
				if isFavorite {
					strongSelf.noticeOnlyText(SWLocalizedString(key: "add_failure"))
				}else {
					strongSelf.noticeOnlyText(SWLocalizedString(key: "cancel_failure"))
				}
				sender.isSelected = !sender.isSelected
			}
		}
	}
	
	//MARK: go to average Page
	@objc private func tapBottomView(tap:UITapGestureRecognizer) {
		let vc:AllDetailViewController = AllDetailViewController()
		vc.symbolName = coinPair?.symbol
		vc.symbolIconUrl = coinPair?.icon
		self.navigationController?.pushViewController(vc, animated: true)
		
		SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Average_PairsDetail_Page)
	}
	
	//MARK: Add subViews
	private func createBottomView() {
		
		bottomView.backgroundColor = UIColor.white
		view.addSubview(bottomView)
		bottomView.snp.makeConstraints { (make) in
			make.left.right.equalTo(view)
			make.height.equalTo(bottomViewH)
			make.bottom.equalTo(view).offset((SWScreen_height == iPhoneXScreenHeight) ? -iPhoneXBottomHeight : 0)
		}
		let ges = UITapGestureRecognizer.init(target: self, action: #selector(tapBottomView(tap:)))
		bottomView.addGestureRecognizer(ges)
		//imageV
		
        bottomView.addSubview(bottomCoinImageV)
//
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 9)
        title.textColor = UIColor.init(hexColor: "333333")
        title.text = SWLocalizedString(key: "average")
        title.textAlignment = .center
        bottomView.addSubview(title)

        let alertBtn = UIButton.init(type: .custom)
        alertBtn.setImage(#imageLiteral(resourceName: "iconalert"), for: .normal)
        alertBtn.setTitle(SWLocalizedString(key: "alert"), for: .normal)
        alertBtn.setTitleColor(.black, for: .normal)
        alertBtn.titleLabel?.font = UIFont.systemFont(ofSize: 9)
        alertBtn.addTarget(self, action: #selector(alertBtnAction(button:)), for: .touchUpInside)
     
        let tempAlertLB = UILabel()
        tempAlertLB.font = UIFont.boldSystemFont(ofSize: 9)
        tempAlertLB.text = alertBtn.titleLabel?.text
        tempAlertLB.sizeToFit()
        
        alertBtn.titleEdgeInsets = UIEdgeInsetsMake(#imageLiteral(resourceName: "iconalert").size.height + 5, -( #imageLiteral(resourceName: "iconalert").size.width), 0,0);
        // button图片的偏移量
        alertBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, tempAlertLB.bounds.size.height + 5, -(tempAlertLB.bounds.size.width))
        bottomView.addSubview(alertBtn)
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Alert_PairsDetail_Page)

		let btn = UIButton()
		btn.backgroundColor = UIColor.init(hexColor: "1E59F5")
		btn.contentHorizontalAlignment = .center
		btn.addTarget(self, action: #selector(didClickFavorite(sender:)), for: UIControlEvents.touchUpInside)
		btn.setImage(#imageLiteral(resourceName: "kLine_favorites"), for: UIControlState.selected)
		btn.setImage(#imageLiteral(resourceName: "kLine_favoritesgrey"), for: UIControlState.normal)
		btn.setTitle(SWLocalizedString(key: "favorite"), for: UIControlState.normal)
//        btn.setTitle(SWLocalizedString(key: "cancel_favorite"), for: UIControlState.selected)
		btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 9)
		btn.isSelected = coinPair?.favorite_status == 1 ? true : false
		
		if btn.isSelected {
			SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_CancelFavorites_PairsDetail_Page)
		}else {
			SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_AddFavorites_PairsDetail_Page)
		}
		let tempLB = UILabel()
		tempLB.text = btn.titleLabel?.text
		tempLB.font = UIFont.boldSystemFont(ofSize: 9)
		tempLB.sizeToFit()
		// button标题的偏移量
		btn.titleEdgeInsets = UIEdgeInsetsMake(#imageLiteral(resourceName: "kLine_favorites").size.height + 5, -( #imageLiteral(resourceName: "kLine_favorites").size.width), 0,0);
		// button图片的偏移量
		btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, tempLB.bounds.size.height + 5, -(tempLB.bounds.size.width));
		bottomView.addSubview(btn)
		
//        bottomCoinImageV.snp.makeConstraints { (make) in
//            make.centerY.equalTo(bottomView)
//            make.left.equalTo(bottomView).offset(15)
//            make.width.height.equalTo(30)
//        }
//        title.snp.makeConstraints { (make) in
//            make.centerY.equalTo(bottomView)
//            make.left.equalTo(bottomCoinImageV.snp.right).offset(15)
////            make.width.equalTo(120)
//        }

        bottomCoinImageV.snp.makeConstraints { (make) in
            make.top.equalTo(8)
            make.left.equalTo(bottomView).offset((120-18)/2)
            make.width.height.equalTo(18)
        }
        title.snp.makeConstraints { (make) in
            make.top.equalTo(bottomCoinImageV.snp.bottom).offset(5)
            make.left.equalTo(bottomView)
            make.width.equalTo(120)
        }

        alertBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(bottomView)
            make.centerX.equalTo(bottomView)
            make.width.equalTo(100)
            make.height.equalTo(bottomView)
        }
		btn.snp.makeConstraints { (make) in
			make.centerY.right.height.top.equalTo(bottomView)
			make.width.equalTo(120)
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
		topCard.frame = CGRect(x: padding, y: padding, width: SWScreen_width - padding * 2 , height: topCardH)
		scrollView.addSubview(topCard)
		
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
		
//		let marketCap = UILabel()
//		marketCap.text = SWLocalizedString(key: "market_cap").uppercased()
//		marketCap.textColor = UIColor.init(hexColor: "BBBBBB")
//		marketCap.font = UIFont.systemFont(ofSize: 10)
		
		let volume = UILabel()
		volume.text = SWLocalizedString(key: "volume_24h").uppercased()
		volume.textColor = UIColor.init(hexColor: "BBBBBB")
		volume.font = UIFont.systemFont(ofSize: 10)
		
		pairRightPriceValue.textColor = UIColor.init(hexColor: "F96C6C")
		pairRightPriceValue.font = UIFont.boldSystemFont(ofSize: 15)
		pairRightPriceValue.text = "--"
		
		volumeValue.textColor = UIColor.init(hexColor: "333333")
		volumeValue.font = UIFont.boldSystemFont(ofSize: 10)
		volumeValue.text = "--"
		
		topView.addSubview(priceLB)
		topView.addSubview(percentLB)
//		topView.addSubview(marketCap)
		topView.addSubview(pairRightPriceValue)
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
//		marketCap.snp.makeConstraints { (make) in
//			make.left.equalTo(volume)
//			make.bottom.equalTo(volume.snp.top).offset(-2)
//		}
		pairRightPriceValue.snp.makeConstraints { (make) in
			make.left.equalTo(volume)
			make.bottom.equalTo(volume.snp.top).offset(-2)
		}
		volumeValue.snp.makeConstraints { (make) in
			make.centerY.equalTo(volume)
			make.left.equalTo(volume.snp.right).offset(6)
		}
	}
	//end
	
	deinit {
		print("deinit ")
        if socket != nil {
            socket.delegate = nil
            socket.disconnect()
            socket = nil
        }
		
		SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_PairsDetail_Page)
	}
}
