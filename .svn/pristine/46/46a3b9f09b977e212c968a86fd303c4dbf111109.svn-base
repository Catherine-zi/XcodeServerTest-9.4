//
//  CoinDetailViewController.swift
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/7/27.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class CoinDetailViewController: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var capView: UIView!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var supplyView: UIView!
    @IBOutlet weak var rateView: UIView!
    @IBOutlet weak var highLowView: UIView!
    
    @IBOutlet weak var priceTitleLbl: UILabel!
    @IBOutlet weak var priceUsdLbl: UILabel!
    @IBOutlet weak var priceUsdRateLbl: UILabel!
    @IBOutlet weak var priceBtcLbl: UILabel!
    @IBOutlet weak var priceBtcRateLbl: UILabel!
    @IBOutlet weak var priceEthLbl: UILabel!
    @IBOutlet weak var priceEthRateLbl: UILabel!
    
    @IBOutlet weak var capTitleLbl: UILabel!
    @IBOutlet weak var capUsdLbl: UILabel!
    @IBOutlet weak var capBtcLbl: UILabel!
    @IBOutlet weak var capEthLbl: UILabel!
    
    @IBOutlet weak var volumnTitleLbl: UILabel!
    @IBOutlet weak var volumnUsdLbl: UILabel!
    @IBOutlet weak var volumnBtcLbl: UILabel!
    @IBOutlet weak var volumnEthLbl: UILabel!
    
    @IBOutlet weak var supplyTotalLbl: UILabel!
    @IBOutlet weak var supplyTotalAmountLbl: UILabel!
    @IBOutlet weak var supplyCirLbl: UILabel!
    @IBOutlet weak var supplyCirAmountLbl: UILabel!
    @IBOutlet weak var supplyRateTitleLbl: UILabel!
    @IBOutlet weak var supplyRateLbl: UILabel!
    
    @IBOutlet weak var high24TitleLbl: UILabel!
    @IBOutlet weak var high24Lbl: UILabel!
    @IBOutlet weak var high52TitleLbl: UILabel!
    @IBOutlet weak var high52Lbl: UILabel!
    @IBOutlet weak var highLftTitleLbl: UILabel!
    @IBOutlet weak var highLftLbl: UILabel!
    
    @IBOutlet weak var low24TitleLbl: UILabel!
    @IBOutlet weak var low24Lbl: UILabel!
    @IBOutlet weak var low52TitleLbl: UILabel!
    @IBOutlet weak var low52Lbl: UILabel!
    @IBOutlet weak var lowLftTitleLbl: UILabel!
    @IBOutlet weak var lowLftLbl: UILabel!
    
    var symbol: String?
    var coinModel: MarketsAllDetailDataStruct?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_MoreMarketsDetail_Page)
        self.setUpViews()
    }
    
    private func setUpViews() {
        self.scrollView.contentInset = UIEdgeInsets.init(top: 44, left: 0, bottom: 0, right: 0)
        self.setShadow(view: self.priceView)
        self.setShadow(view: self.capView)
//        self.setShadow(view: self.volumeView)
        self.setShadow(view: self.supplyView)
        
        self.titleLbl.text = (self.coinModel?.symbol ?? "") + " " + SWLocalizedString(key: "coin_detail").uppercased()
        self.priceTitleLbl.text = SWLocalizedString(key: "price").uppercased()
        self.capTitleLbl.text = SWLocalizedString(key: "market_cap").uppercased()
        self.volumnTitleLbl.text = SWLocalizedString(key: "volume_24h").uppercased()
        self.supplyTotalLbl.text = SWLocalizedString(key: "total_supply").uppercased()
        self.supplyCirLbl.text = SWLocalizedString(key: "cir_supply").uppercased()
        self.supplyRateTitleLbl.text = SWLocalizedString(key: "rate").uppercased()
        self.high24TitleLbl.text = SWLocalizedString(key: "high") + "(" + SWLocalizedString(key: "day") + ")"
        self.high52TitleLbl.text = SWLocalizedString(key: "high") + "(" + SWLocalizedString(key: "week52") + ")"
        self.highLftTitleLbl.text = SWLocalizedString(key: "high") + "(" + SWLocalizedString(key: "lft") + ")"
        self.low24TitleLbl.text = SWLocalizedString(key: "low") + "(" + SWLocalizedString(key: "day") + ")"
        self.low52TitleLbl.text = SWLocalizedString(key: "low") + "(" + SWLocalizedString(key: "week52") + ")"
        self.lowLftTitleLbl.text = SWLocalizedString(key: "low") + "(" + SWLocalizedString(key: "lft") + ")"
        
        self.checkData()
    }
    
    private func checkData() {
        if self.coinModel == nil {
            self.networkRequest()
        } else {
            self.setContent()
        }
    }
    
    private func networkRequest() {
        guard let symbol = self.symbol else {
            return
        }
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
                self?.setContent()
            }
        }
    }
    
    private func setContent() {
        
        guard let model = self.coinModel else {
            return
        }
        self.priceUsdLbl.text = "$" + self.roundAmount(amount: model.priceUsd)
		
        self.priceUsdRateLbl.text = self.roundAmountForPercent(amount: model.percentChange24h) + "%"
        self.priceUsdRateLbl.textColor = self.getColor(amount: model.percentChange24h)
        self.priceBtcLbl.text = self.roundAmount(amount: model.priceBtc) + " BTC"
        self.priceBtcRateLbl.text = self.roundAmountForPercent(amount: model.percentChange24hBtc) + "%"
        self.priceBtcRateLbl.textColor = self.getColor(amount: model.percentChange24hBtc)
        self.priceEthLbl.text = self.roundAmount(amount: model.priceEth) + " ETH"
        self.priceEthRateLbl.text = self.roundAmountForPercent(amount: model.percentChange24hEth) + "%"
        self.priceEthRateLbl.textColor = self.getColor(amount: model.percentChange24hEth)
		
		
        self.capUsdLbl.text = "$" + self.roundAmount(amount: model.marketCapUsd)
        self.capBtcLbl.text = self.roundAmount(amount: model.marketCapBtc) + " BTC"
        self.capEthLbl.text = self.roundAmount(amount: model.marketCapEth) + " ETH"
        
        self.volumnUsdLbl.text = "$" + self.roundAmount(amount: model.volumeUsd)
        self.volumnBtcLbl.text = self.roundAmount(amount: model.volume24hBtc) + " BTC"
        self.volumnEthLbl.text = self.roundAmount(amount: model.volume24hEth) + " ETH"
        
        self.supplyTotalAmountLbl.text = self.roundAmount(amount: model.totalSupply) + " " + (model.symbol ?? "")
        self.supplyCirAmountLbl.text = self.roundAmount(amount: model.availableSupply) + " " + (model.symbol ?? "")
        var rate = Decimal()
        if let totalStr = model.totalSupply,
            let cirStr = model.availableSupply,
            let total = Decimal(string: totalStr),
            let cir = Decimal(string: cirStr) {
            rate = (cir / total * 100)
			
        }
		
        self.supplyRateLbl.text = SwiftExchanger.shared.getRoundedNumberString(numberString: rate.description, decimalCount: 4) + "%"//self.roundAmount(amount: rate.description) + "%"
        
        self.high24Lbl.text = "$" + self.roundAmount(amount: model.highPriceUsd)
        self.high52Lbl.text = "$" + self.roundAmount(amount: model.priceHeight52weeks)
        self.highLftLbl.text = "$" + self.roundAmount(amount: model.priceHeightAll)
        self.low24Lbl.text = "$" + self.roundAmount(amount: model.lowPriceUsd)
        self.low52Lbl.text = "$" + self.roundAmount(amount: model.priceLow52weeks)
        self.lowLftLbl.text = "$" + self.roundAmount(amount: model.priceLowAll)
    }
    
    private func setShadow(view: UIView) {
        view.layer.shadowRadius = 2
        view.layer.shadowColor = UIColor.init(hexColor: "EBEBEB").cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowOpacity = 0.7
        view.layer.masksToBounds = false
    }
    
    private func getColor(amount: String?) -> UIColor {
        if let decim = Decimal(string: amount ?? "") {
            if decim < 0 {
                return GainsDownColor
            }
        }
        return GainsUpColor
    }

	private func roundAmountForPercent(amount: String?) -> String {
		var result = amount
		if let str = amount,
			let decim = Decimal(string: str)
		{
			if decim < 0 {
				result = decim.description
			}else {
				result = "+" + decim.description
			}
		}
		return result ?? "0"
		
	}
    private func roundAmount(amount: String?) -> String {
        var result = amount
        if let str = amount,
            let decim = Decimal(string: str)
        {
            result = decim.description
        }
        return result ?? "0"
//        return SwiftExchanger.shared.getRoundedNumberString(numberString: (amount ?? ""), decimalCount: 8)
    }
    @IBAction func supplyRateQuestionTapped(_ sender: Any) {
        let visual = UIView()
        visual.backgroundColor = UIColor.init(white: 1, alpha: 0.8)
        visual.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
//        let visual = VisualEffectView.visualEffectView(frame: view.bounds)
        let successView = Bundle.main.loadNibNamed("RateHintView", owner: nil, options: nil)?.first as! RateHintView
        visual.addSubview(successView)
        successView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(visual)
			make.height.equalTo(180)
			make.left.equalTo(visual).offset(20)
			make.right.equalTo(visual).offset(-20)
        }
        view.addSubview(visual)
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_RateFormula_popup)
        
        successView.confirmBlock = {[weak visual] in
            visual?.removeFromSuperview()
        }
    }
    @IBAction func backTapped(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_MoreMarketsDetail_Page)
        self.navigationController?.popViewController(animated: true)
    }
}
