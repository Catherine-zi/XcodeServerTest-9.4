//
//  ExchangeDetailViewController.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/12.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class ExchangeDetailViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
	
    public var exchangeName:String?
    var totalVolume: String?

    @IBOutlet weak var topViewConstranit_height: NSLayoutConstraint!
    //    public var rank:String?

    var exchangeDetailList: [MarketsExchangeDetailDataStruct] = []
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var allTitleLabel: UILabel!
    @IBOutlet weak var volumeTitleLabel: UILabel!
    @IBOutlet weak var priceTitleLabel: UILabel!
    @IBOutlet weak var volTitleLabel: UILabel!

	@IBOutlet weak var coinTitleLB: UILabel!
	
	@IBOutlet weak var fitSENameRightMargin: NSLayoutConstraint!
	@IBOutlet weak var fitSEVolumeW: NSLayoutConstraint!
    @IBOutlet weak var totalVolumeLbl: UILabel!
    
	@IBOutlet weak var mainTab: UITableView!
	@IBAction func clickBackBtn(_ sender: Any) {
        
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_ExchangeDetail_Page)

		self.navigationController?.popViewController(animated: true)
	}
//    @IBAction func clickSearchBtn(_ sender: Any) {
//        let vc:MarketsSearchViewController = MarketsSearchViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
	
	override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_ExchangeDetail_Page)

		setUpViews()
        //mainTab
        mainTab.delegate = self
        mainTab.dataSource = self
        mainTab.separatorStyle = .none
        mainTab.register(UINib.init(nibName: "ExchangeDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "ExchangeDetailTableViewCell")
        self.requestNetworkData(pageNo: 0)

        mainTab.mj_header = SwiftDiyHeader(refreshingBlock: {
            self.requestNetworkData(pageNo: 0)
        })
        mainTab.mj_header.lastUpdatedTimeKey = "ExchangeDetailViewController"
        mainTab.mj_footer = MJRefreshAutoFooter.init(refreshingBlock: {
            self.requestNetworkData(pageNo:self.exchangeDetailList.count)
        })
        
    }

	private func setUpViews() {
		navTitleLabel.text = SWLocalizedString(key: "exchange_detail")
        allTitleLabel.text = SWLocalizedString(key: "name")
        volumeTitleLabel.text = SWLocalizedString(key: "volume_24h")
        priceTitleLabel.text = SWLocalizedString(key: "price")
        volTitleLabel.text = SWLocalizedString(key: "vol_percent")
        
    //Attr label
//        let attr:NSMutableAttributedString = NSMutableAttributedString.init(attributedString: NSAttributedString.init(string: String(exchangeDetailList.count), attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15).boldItalic,
//                                                                                                                                                NSAttributedStringKey.foregroundColor : UIColor.init(hexColor: "356AF6")]))
      
//        attr.append(NSAttributedString.init(string: exchangeName!, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15)
//            ,NSAttributedStringKey.foregroundColor : UIColor.init(hexColor: "333333")]))
        let attr:NSMutableAttributedString = NSMutableAttributedString.init(string: exchangeName!, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15)
            ,NSAttributedStringKey.foregroundColor : UIColor.init(hexColor: "333333")])
		coinTitleLB.attributedText = attr
		
		//fit 320
		if SWScreen_width == 320.0 {
			fitSENameRightMargin.constant = 0
			fitSEVolumeW.constant = 45
		}
        guard let totalStr = self.totalVolume, totalStr.count > 0 else {
            self.topViewConstranit_height.constant = 0
            return
        }
        var totalNumber = ""
        if let totalStr = self.totalVolume,
            let totalDecim = Decimal(string: totalStr) {
            totalNumber = SwiftExchanger.shared.getFormattedCurrencyString(amount: totalDecim, inDollar: true, short: false)
        } else {
            totalNumber = SwiftExchanger.shared.getFormattedCurrencyString(amount: Decimal(), inDollar: true, short: false)
        }
        self.totalVolumeLbl.text = String(format: "%@:%@", arguments: [SWLocalizedString(key: "total_volume"), totalNumber])
		
		
		
	}
    func requestNetworkData(pageNo: Int) {
        
        MarketsAPIProvider.request(MarketsAPI.markets_exchangesDetail(pageNo, 20, exchangeName!)) { [weak self](result) in
            
            self?.mainTab.mj_header.endRefreshing()
            self?.mainTab.mj_footer.endRefreshing()
            
            if case let .success(response) = result {
                
                let decryptedData:Data = Data.init(decryptionResponseData: response.data)
                if decryptedData.count == 0 {
                    print("decryptedData is nil")
                    return
                }
                let json = try? JSONDecoder().decode(MarketsExchangeDetailStruct.self, from: decryptedData)
                if json?.code != 0 {
                    print("json: \(String(describing: json ?? nil))")
                    return
                }
                DispatchQueue.main.async {
                    if pageNo == 0 {
                        self?.exchangeDetailList.removeAll()
                    }
                    for symbol:MarketsExchangeDetailDataStruct in (json?.data)! {
                        self?.exchangeDetailList.append(symbol)
                    }
                    self?.mainTab.reloadData()
                }
            } else {
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
            }
        }
    }

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.exchangeDetailList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:ExchangeDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ExchangeDetailTableViewCell") as! ExchangeDetailTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
		cell.backView.backgroundColor = (indexPath.row % 2) == 0 ? UIColor.init(hexColor: "F8F8F8") : UIColor.init(hexColor: "FFFFFF")
        let model:MarketsExchangeDetailDataStruct = self.exchangeDetailList[indexPath.row]
        cell.fillDataWithSymbolStruct(detailStruct: model, indexPath: indexPath)
		return cell
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}

}
