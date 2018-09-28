//
//  KLineView.swift
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/8/2.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit
import HSStockChart

let timeTypeBtnW: CGFloat = 60
let btnH: CGFloat = 30
private let kLineMarjin:CGFloat = 10
//let kLineH:CGFloat = 230
let cornerRadius:CGFloat = 4
let minArr = [
	SWLocalizedString(key: "min"),
	SWLocalizedString(key: "1 min"),
	SWLocalizedString(key: "5 min"),
	SWLocalizedString(key: "15 min"),
	SWLocalizedString(key: "30 min")]
let hourArr = [
	SWLocalizedString(key: "HOUR"),
	SWLocalizedString(key: "1 hour"),
	SWLocalizedString(key: "2 hour"),
	SWLocalizedString(key: "4 hour"),
	SWLocalizedString(key: "6 hour")]

class KLineView: UIView,KLineDelegate {
	
	var transactionPairTitle:String?
	var exchangeName:String?
	private let defaultAmount:String = "100"
	private var currentTimeType:String = "1h"
	
	private let timesBackView = UIView()
	private let kLineView = UIView()
	private let errorTip = UILabel()
	private var hsChartType:HSChartType = .kLineForDay
	var stockChartView:HSKLineView!
	private let indicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
	private lazy var loadingView:SwiftDiyLoading = {
		let loading = SwiftDiyLoading.init(frame: stockChartView.frame)
		loading.backgroundColor = stockChartView.backgroundColor
		kLineView.addSubview(loading)
		return loading
	}()
	
	private var expansionMinBtn:AllDetailDiyButton?
	private var expansionHourBtn:AllDetailDiyButton?
	
	var expansionV:ExpansionView!
	var expansionHour:ExpansionView!
	
	private var isLoading:Bool = false
	
	convenience init(frame: CGRect,isFullScreen: Bool,exchangeName: String?,transactionPairTitle: String?,klineType: HSChartType,currentTimeType: String) {
		self.init(frame: frame)
		
		self.backgroundColor = UIColor.init(hexColor: "F2F2F2")
		self.exchangeName = exchangeName
		self.transactionPairTitle = transactionPairTitle
		setUpViews(isFullScreen: isFullScreen,klineType: klineType,currentTimeType: currentTimeType)
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	//MARK: setupViews
	private func setUpViews(isFullScreen: Bool,klineType: HSChartType,currentTimeType: String) {
		
		createTimeBack(isFullScreen: isFullScreen)
		
//		add expansionview
		let minframe = timesBackView.convert((expansionMinBtn?.frame)!, to: self)
		expansionV = ExpansionView.init(btnArr: Array(minArr.suffix(from: 1)), title: minArr.first!,frame:  CGRect.init(x: minframe.origin.x, y: minframe.origin.y + minframe.size.height, width: minframe.size.width, height: minframe.size.height))
		expansionV.isHidden = true
		expansionV.delegate = self
		self.addSubview(expansionV)

		let hourFrame = timesBackView.convert(expansionHourBtn!.frame, to: self)
		expansionHour = ExpansionView.init(btnArr: Array(hourArr.suffix(from: 1)), title: hourArr.first!,frame: CGRect.init(x: hourFrame.origin.x, y: hourFrame.origin.y + hourFrame.size.height, width: hourFrame.size.width, height: hourFrame.size.height))
		expansionHour.isHidden = true
		expansionHour.delegate = self
		self.addSubview(expansionHour)
		
		//add kLineView
		kLineView.backgroundColor = self.backgroundColor
		self.addSubview(kLineView)
		kLineView.snp.makeConstraints { (make) in
			make.left.right.bottom.equalTo(self)
			make.top.equalTo(self).offset(btnH + kLineMarjin)
		}
		let legendTitle = ["",//time
			SWLocalizedString(key: "open").lowercased(),
			SWLocalizedString(key: "high").lowercased(),
			SWLocalizedString(key: "low").lowercased(),
			SWLocalizedString(key: "close_price").lowercased(),
			SWLocalizedString(key: "volume").lowercased(),
			"",//对应的value
			"",
			"",
			"",
			""]
		stockChartView = HSKLineView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height - (btnH + kLineMarjin)), kLineType: klineType, isNeedReverseColor: TelegramUserInfo.shareInstance.settingColorFlag, legendTitle:legendTitle)
		stockChartView.tag = hsChartType.rawValue
		stockChartView.isLandscapeMode = false
		stockChartView.backgroundColor = kLineView.backgroundColor
		stockChartView.isHidden = true
		stockChartView.loadMoreClosure = { [weak self](endTime:String) in
			
			self?.getKLineData(exchangeName: self?.exchangeName ?? "", transactionPairName: self?.transactionPairTitle ?? "", amount: self?.defaultAmount ?? "100", endTime: endTime,isLoadMore: true)
		}
		kLineView.addSubview(stockChartView)
		
		//loadingView
		loadingView.isHidden = true
		indicator.center = CGPoint(x: 15, y: loadingView.frame.size.height * 0.5)
		indicator.isHidden = true
		kLineView.addSubview(indicator)
		//errorTip
		errorTip.font = UIFont.boldSystemFont(ofSize: 12)
		errorTip.textColor = UIColor.init(hexColor: "BBBBBB")
		errorTip.text = SWLocalizedString(key: "kline_not_support")
		errorTip.isHidden = true
		errorTip.textAlignment = .center
		errorTip.numberOfLines = 0
		kLineView.addSubview(errorTip)
		
		errorTip.snp.makeConstraints { (make) in
			make.centerX.centerY.equalTo(kLineView)
			make.width.equalTo(225)
		}
		
		//default selected 1hour
		expansionV.hiddenExpansion()
		expansionHour.showMore()

		if !isFullScreen {
			let tempBtn = UIButton()
			tempBtn.tag = 0//1hour
			
			expansionHour.clickBtn(sender: tempBtn)
		}else {
			//选择默认的timeType
			self.currentTimeType = currentTimeType
			var tag = 0
			var isHourExpanV = false
			if currentTimeType == "1h" {
				tag = 100
				isHourExpanV = true
			}else if currentTimeType == "2h" {
				tag = 101
				isHourExpanV = true
			}else if currentTimeType == "4h" {
				tag = 102
				isHourExpanV = true
			}else if currentTimeType == "6h" {
				tag = 103
				isHourExpanV = true
			}else if currentTimeType == "1m" {
				tag = 100
			}else if currentTimeType == "5m" {
				tag = 101
			}else if currentTimeType == "15m" {
				tag = 102
			}else if currentTimeType == "30m" {
				tag = 103
			}else if currentTimeType == "1d" {
				tag = 2
			}else if currentTimeType == "1w" {
				tag = 3
			}
			changeBtnStatus(tag: tag, isHourExpanV: isHourExpanV)
		}
		
	}
	
	private func createTimeBack(isFullScreen: Bool) {
		
		self.addSubview(timesBackView)
		
		
		let arr:Array<String> = [minArr.first!, hourArr.first!,SWLocalizedString(key: "day"),SWLocalizedString(key: "week")]
		
		var flag:Int = 0
		let btnW:CGFloat = timeTypeBtnW//SWScreen_width == 320.0 ? 45 : 50
		
		let padding:CGFloat = 15
		var btnX:CGFloat = padding
		let btnY:CGFloat = 0
		
		let fullScreenW:CGFloat = timeTypeBtnW + padding
		timesBackView.snp.makeConstraints { (make) in
			make.top.left.equalTo(self)
			make.right.equalTo(self).offset(-fullScreenW)
			make.height.equalTo(btnH)
		}
		
		let fullScreenBtn = UIButton()
		fullScreenBtn.setImage(#imageLiteral(resourceName: "kline_fullScreen"), for: UIControlState.normal)
		fullScreenBtn.setImage(#imageLiteral(resourceName: "kline_halfScreen"), for: UIControlState.selected)
		fullScreenBtn.addTarget(self, action: #selector(clickFullScreenBtn(sender:)), for: .touchUpInside)
		fullScreenBtn.isSelected = isFullScreen
		
		self.addSubview(fullScreenBtn)
		fullScreenBtn.snp.makeConstraints { (make) in
			make.centerY.equalTo(timesBackView)
			make.right.equalTo(self).offset(-padding)
			make.height.width.equalTo(timeTypeBtnW)
		}
		
		let margin:CGFloat = (self.bounds.size.width - btnW * CGFloat(arr.count + 1) - padding * 2)/CGFloat(arr.count)
		
//		let defaultSelect = 2
		for title in arr {
			
			let btn:AllDetailDiyButton = AllDetailDiyButton()
			btn.setTitle(title.uppercased(), for: .normal)
			btn.tag = flag
			btn.isSelected = false
			btn.addTarget(self, action: #selector(didClickTimeBtn(sender:)), for: .touchUpInside)
			btn.frame = CGRect.init(x: btnX, y: btnY, width: btnW, height: btnH)
			timesBackView.addSubview(btn)
			
			if flag == 0 || flag == 1 {
				
				//expansion
				setBtnSpecialStatus(sender: btn, isSpecial: false)
				btn.isSelected = true
				btnImageOnRight(sender: btn)
				
				if flag == 0 {
					expansionMinBtn = btn
				}else {
					expansionHourBtn = btn
				}
				
			}
			
			flag = flag + 1
			btnX = padding + ((btnW + margin) * CGFloat(flag))
			
		}
	}
	//MARK: 点击全屏
	@objc private func clickFullScreenBtn(sender:UIButton) {
		
		guard let tabBar:SWTabBarController = UIApplication.shared.keyWindow?.rootViewController as? SWTabBarController else {
			return
		}
		if sender.isSelected {//全屏状态，回归竖屏
			tabBar.allowRotation = false
			
			let value = UIInterfaceOrientation.portrait.rawValue
			UIDevice.current.setValue(value, forKey: "orientation")
			
			self.viewController().dismiss(animated: true, completion: nil)
		}else {
			
			let fullScreenDataK = self.stockChartView.dataK
			if fullScreenDataK.count == 0 {
				return
			}
			
			tabBar.allowRotation = true

			let value = UIInterfaceOrientation.landscapeLeft.rawValue
			UIDevice.current.setValue(value, forKey: "orientation")
			
			let vc = KlineFullScreenViewController()
			vc.transactionPairTitle = self.transactionPairTitle
			vc.exchangeName = self.exchangeName
			vc.dataK = fullScreenDataK
			vc.klineType = stockChartView.kLineType
			vc.currentTimeType = self.currentTimeType
			self.viewController().navigationController?.present(vc, animated: true, completion: nil)
			
			self.viewController().view.isHidden = true
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
				self.viewController().view.isHidden = false
			}
		}
		
		
		
	}
	
	func clickTimeType(type: KLineMinType,isHourExpanV: Bool) {
		
		var typeStr:String
		var btnTypeStr:String
		switch type {
		case .oneMin:
			typeStr = "1m"
			btnTypeStr = "1MIN"
			self.stockChartView.kLineType = HSChartType.kLineForMinutes
			SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_1Minute_PairsDetail_Page)
		case .fiveMin:
			typeStr = "5m"
			btnTypeStr = "5MIN"
			self.stockChartView.kLineType = HSChartType.kLineForMinutes
			SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_5Minutes_PairsDetail_Page)
		case .fifteenMin:
			typeStr = "15m"
			btnTypeStr = "15MIN"
			self.stockChartView.kLineType = HSChartType.kLineForMinutes
			SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_15Minutes_PairsDetail_Page)
		case .thirtyMin:
			typeStr = "30m"
			btnTypeStr = "30MIN"
			self.stockChartView.kLineType = HSChartType.kLineForMinutes
			SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_30Minutes_PairsDetail_Page)
		case .oneHour:
			typeStr = "1h"
			btnTypeStr = "1HOUR"
			self.stockChartView.kLineType = HSChartType.kLineForHour
			SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_1Hour_PairsDetail_Page)
		case .twoHour:
			typeStr = "2h"
			btnTypeStr = "2HOUR"
			self.stockChartView.kLineType = HSChartType.kLineForHour
			SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_2Hour_PairsDetail_Page)
		case .fourHour:
			typeStr = "4h"
			btnTypeStr = "4HOUR"
			self.stockChartView.kLineType = HSChartType.kLineForHour
			SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_4Hour_PairsDetail_Page)
		case .sixHour:
			typeStr = "6h"
			btnTypeStr = "6HOUR"
			self.stockChartView.kLineType = HSChartType.kLineForHour
			SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_6Hour_PairsDetail_Page)
		default:
			typeStr = "1h"
			btnTypeStr = "1MIN"
			self.stockChartView.kLineType = HSChartType.kLineForHour
		}
		//change btn status
		if isHourExpanV {
			expansionHourBtn?.setTitle(btnTypeStr, for: .normal)
		}else {
			expansionMinBtn?.setTitle(btnTypeStr, for: .normal)
		}
		reloadTimeBackBtnsStatus(isHourExpanV: isHourExpanV,isSelected: true)
		//load Data
		self.currentTimeType = typeStr
		getKLineData(exchangeName: exchangeName ?? "", transactionPairName: transactionPairTitle ?? "", amount: defaultAmount, endTime: String(Date().timeIntervalSince1970),isLoadMore: false)
	}
	//MARK: 用于刷新，MIN或HOUR点击时，改变头部按钮的状态
	private func reloadTimeBackBtnsStatus(isHourExpanV: Bool,isSelected: Bool) {
		

		for subView in timesBackView.subviews  {
			
			if subView.isKind(of: AllDetailDiyButton.classForCoder()) {
				let btn:AllDetailDiyButton = subView as! AllDetailDiyButton
				
				if btn.tag == 2 || btn.tag == 3 {
					btn.isSelected = false
					continue
				}
				
				//MIN OR HOUR
				let needChangeTag = isHourExpanV ? 1 : 0
				if btn.tag == needChangeTag{
					setBtnSpecialStatus(sender: btn, isSpecial: true)
					btn.isSelected = isSelected
				}else {
					setBtnSpecialStatus(sender: btn, isSpecial: false)
					btn.isSelected = true
				}
				btnImageOnRight(sender: btn)
				
			}
		}
		
	}
	
	@objc private func didClickTimeBtn(sender:AllDetailDiyButton) {
		
		let tag = sender.tag
		//改变按钮的状态
		if tag == 2 || tag == 3 {//day,week
			
			for subView in timesBackView.subviews  {
				
				if subView.isKind(of: AllDetailDiyButton.classForCoder()) {
					let btn:AllDetailDiyButton = subView as! AllDetailDiyButton
					btn.isSelected = btn.tag == tag ? true : false
					
					if btn.tag == 0 || btn.tag == 1 {
						setBtnSpecialStatus(sender: btn, isSpecial: false)
						btn.isSelected = true
					}
				}
			}
			expansionV.hiddenExpansion()
			expansionHour.hiddenExpansion()
			
		}else {//Min,Hour
			
			if tag == 0 {//Min
				
				
				if sender.isSelected == true {
					expansionV.showMore()
					expansionHour.hiddenExpansion()
				}else {
					expansionV.hiddenExpansion()
					expansionHour.hiddenExpansion()
				}
				
				expansionHourBtn?.isSelected = true
				
			}else {//HOUR
				
				if sender.isSelected == true {
					expansionHour.showMore()
					expansionV.hiddenExpansion()
				}else {
					expansionHour.hiddenExpansion()
					expansionV.hiddenExpansion()
				}
				
				expansionMinBtn?.isSelected = true
			}
			
			
			sender.isSelected = !sender.isSelected
		}
	
		
		
		//接口的数据加载
		if sender.tag != 2 && sender.tag != 3 {
			return
		}
		var typeStr:String
		switch sender.tag {
		case 2:
			typeStr = "1d"
			self.stockChartView.kLineType = HSChartType.kLineForDay
			SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_1Day_PairsDetail_Page)
		case 3:
			typeStr = "1w"
			self.stockChartView.kLineType = HSChartType.kLineForWeek
			SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_1Week_PairsDetail_Page)
		default:
			typeStr = "1d"
		}
		self.currentTimeType = typeStr
		getKLineData(exchangeName: exchangeName ?? "", transactionPairName: transactionPairTitle ?? "", amount: defaultAmount, endTime: String(Date().timeIntervalSince1970), isLoadMore: false)
		//end
		
	}
	//MARK: 改变按钮的状态，只用于转换成全屏时，选中某个按钮
	func changeBtnStatus(tag: Int,isHourExpanV: Bool) {
		if tag >= 100 {
			
			
			if isHourExpanV {//Hour
				let tag = tag - 100
				expansionHour.changeBtnStatus(tag: tag)
				if tag + 1 < hourArr.count {
					var str:String = hourArr[tag + 1].uppercased()
					str = str.replacingOccurrences(of: " ", with: "")
					expansionHourBtn?.setTitle(str, for: .normal)
				}
				
			}else {//Min
				let tag = tag - 100
				expansionV.changeBtnStatus(tag: tag)
				if tag + 1 < hourArr.count {
					var str:String = minArr[tag + 1].uppercased()
					str = str.replacingOccurrences(of: " ", with: "")
					expansionMinBtn?.setTitle(str, for: .normal)
				}
			}
			
			reloadTimeBackBtnsStatus(isHourExpanV: isHourExpanV,isSelected: true)
			
		}else {//week or day
			
			for subView in timesBackView.subviews  {
				
				if subView.isKind(of: AllDetailDiyButton.classForCoder()) {
					let btn:AllDetailDiyButton = subView as! AllDetailDiyButton
					btn.isSelected = btn.tag == tag ? true : false
					
					if btn.tag == 0 || btn.tag == 1 {
						setBtnSpecialStatus(sender: btn, isSpecial: false)
						btn.isSelected = true
					}
				}
			}
		}
		
		expansionHour.hiddenExpansion()
		expansionV.hiddenExpansion()
	}
	
	private func btnImageOnRight(sender: AllDetailDiyButton){
		let btnImageW:CGFloat = sender.imageView!.bounds.size.width
		let btnTitleW:CGFloat = sender.titleLabel!.bounds.size.width
		let spacing:CGFloat = 2.0
		sender.titleEdgeInsets = UIEdgeInsetsMake(0, -(btnImageW * 2) - spacing, 0.0, 0.0)
		sender.imageEdgeInsets = UIEdgeInsetsMake(0, 0.0, 0.0,-(btnTitleW * 2) - spacing)
	}
	private func setBtnSpecialStatus(sender: UIButton,isSpecial: Bool) {
		
		if isSpecial {
			
			sender.setImage(#imageLiteral(resourceName: "iconBlue"), for: .selected)
			sender.setImage(#imageLiteral(resourceName: "iconPULL"), for: .normal)
			sender.setTitleColor(UIColor.init(hexColor: "356AF6"), for: .selected)
			sender.setTitleColor(UIColor.init(hexColor: "356AF6"), for: .normal)
		} else{
			sender.setImage(#imageLiteral(resourceName: "kLine_pullgrey"), for: .normal)
			sender.setTitleColor(UIColor.init(hexColor: "999999"), for: .normal)
			sender.setImage(#imageLiteral(resourceName: "kLine_pullgrey"), for: .selected)
			sender.setTitleColor(UIColor.init(hexColor: "999999"), for: .selected)
		}
	}
	//MARK: get api data (1m.5m 15m,30m,1h,2h..1d.1w)
	func getKLineData(exchangeName:String,transactionPairName:String,amount:String,endTime:String,isLoadMore:Bool) {
		
		errorTip.isHidden = true
		
		if isLoadMore {
			if isLoading {
				return
			}
			isLoading = true
			
			indicator.isHidden = false
			indicator.startAnimating()
		}else {
			self.isLoading = false
			
			stockChartView.isHidden = true
			loadingView.isHidden = false
			loadingView.startLoading()
		}
		MarketsAPIProvider.request(MarketsAPI.markets_kLine(exchangeName, transactionPairName, amount, self.currentTimeType, endTime)) { [weak self](result) in
			
			guard let strongSelf = self else {
				return
			}
			strongSelf.isLoading = false
	
			if case let .success(response) = result {

				let decryptedData = Data.init(decryptionResponseData: response.data)
				let json = try? JSONDecoder().decode(MarketKLineStruct.self, from: decryptedData)
			
				DispatchQueue.main.async(execute: {
					
					if json?.code != 0 {
						strongSelf.showErrorTip()
						if !isLoadMore {
							strongSelf.loadingView.stopLoading()
							strongSelf.loadingView.isHidden = true
						}else {
							strongSelf.indicator.stopAnimating()
							strongSelf.indicator.isHidden = true
						}
						return
					}
					if !isLoadMore {//recover loadmore status
						strongSelf.stockChartView.loadCompleted = false
					}
					
					//接口回调成功，判断是否有值
					if let klineModel = json?.data?.list,klineModel.count != 0 {
						//count > 0
						
						let tmpDataK:[HSKLineModel] = strongSelf.getKLineModelArray(dataArr: klineModel)
						
						if isLoadMore {
							//防止数据重复
							if tmpDataK.first?.originDate != strongSelf.stockChartView.dataK.first?.originDate {
								strongSelf.stockChartView.configureView(data: tmpDataK + strongSelf.stockChartView.dataK,isLoadMore: isLoadMore)
							}
						}else {
							strongSelf.stockChartView.configureView(data: tmpDataK,isLoadMore: isLoadMore)
						}
						
						if !isLoadMore {
							strongSelf.loadingView.stopLoading()
							strongSelf.loadingView.isHidden = true
						}else {
							strongSelf.indicator.stopAnimating()
							strongSelf.indicator.isHidden = true
						}
						strongSelf.errorTip.isHidden = true
						strongSelf.stockChartView.isHidden = false
					}else {
						if isLoadMore {
							//load completed
							strongSelf.stockChartView.loadCompleted = true
							strongSelf.indicator.stopAnimating()
							strongSelf.indicator.isHidden = true
						}else {
							strongSelf.showErrorTip()
							strongSelf.loadingView.stopLoading()
							strongSelf.loadingView.isHidden = true
							
						}
					}
					
					
				})
			}else {

				if !isLoadMore {
					strongSelf.loadingView.stopLoading()
					strongSelf.loadingView.isHidden = true
					
				}else {
					strongSelf.indicator.stopAnimating()
					strongSelf.indicator.isHidden = true
				}
				
				strongSelf.noticeOnlyText(SWLocalizedString(key: "network_error"))
			}
			
		}
	}
	
	//show error tip
	private func showErrorTip() {
		self.errorTip.isHidden = false
		self.stockChartView.isHidden = true
		
		SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_Empty_PairsDetail_Page)
	}
	//
	func getKLineModelArray(dataArr:Array<KLineStruct>) -> Array<HSKLineModel>{
		
		var klineModel:Array<HSKLineModel> = []
		
		if dataArr.count == 0 {
			return []
		}
		
		let dateFormatter:DateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyyMMddHHmmss"
		
		for kline in dataArr {//.reversed()
			let model = HSKLineModel()
			
			guard let openStr = kline.openPrice,let dOpen = Double(openStr),
				let closeStr = kline.closePrice,let dClose = Double(closeStr),
				let highStr = kline.highPrice,let dHigh = Double(highStr),
				let lowStr = kline.lowPrice,let dLow = Double(lowStr),
				let volumeStr = kline.volume,let dVolume = Double(volumeStr),
				let timeStr = kline.dateline,let dTime = Double(timeStr) else {
					continue
			}
			
			model.open = CGFloat(dOpen)
			model.close = CGFloat(dClose)
			model.high = CGFloat(dHigh)
			model.low = CGFloat(dLow)
			model.volume = CGFloat(dVolume)
			model.date = dateFormatter.string(from: Date.init(timeIntervalSince1970: dTime))
			model.originDate = timeStr
			klineModel.append(model)
			
		}
		
		return klineModel
	}
	

}


