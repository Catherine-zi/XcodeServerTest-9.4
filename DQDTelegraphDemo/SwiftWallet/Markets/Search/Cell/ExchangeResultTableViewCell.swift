//
//  ExchangeResultTableViewCell.swift
//  DQDTelegraphDemo
//
//  Created by AVAZU on 2018/8/3.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class ExchangeResultTableViewCell: UITableViewCell,UITableViewDelegate, UITableViewDataSource {
    
    var exchangeTitleList:[String] = []
    var exchangePairList:[SearchExchangePairContentStruct] = []
    var selectedExchangeName: String?

    var searchExchangePairsResultDic : Dictionary? = [:] {
        didSet {
            if searchExchangePairsResultDic == nil {
                return
            }
            exchangeTitleList.removeAll()
            for key in searchExchangePairsResultDic!.keys {
                exchangeTitleList.append(key as! String )
            }
            selectedExchangeName = exchangeTitleList.first
            exchangePairList = searchExchangePairsResultDic![selectedExchangeName!] as! [SearchExchangePairContentStruct]
//            for value in searchExchangePairsResultDic!.values {
//                exchangePairList = value as! [SearchExchangePairContentStruct]
//            }
            setUpViews()
        }
    }
    
    private let table = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.plain)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        setUpViews()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    private func setUpViews() {
        self.table.backgroundColor = self.contentView.backgroundColor
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none

        table.register(UINib.init(nibName: "MarketsSearchResultCell", bundle: nil), forCellReuseIdentifier: "MarketsSearchResultCell")
        table.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "UITableViewCell")

        self.contentView.addSubview(self.table)
        table.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
        self.table.reloadData()

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : exchangePairList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 35 : 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
            
            for subView in cell.contentView.subviews {
                subView.removeFromSuperview()
            }
            
            let exchangeHeader: SearchExchangeHeaderView = Bundle.main.loadNibNamed("SearchExchangeHeaderView", owner: self, options: nil)!.first as! SearchExchangeHeaderView
            exchangeHeader.frame = CGRect.init(x: 0, y: 0, width:  self.frame.size.width, height: 35)
            exchangeHeader.loadView(titles: self.exchangeTitleList, selectedKey: nil)
            //交易所名称被点击
            exchangeHeader.buttonActionBlock = { [weak self ](btnTag) in
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Huobi_SearchResultPage)

                let key: String = (self?.exchangeTitleList[btnTag-100])!
                self?.selectedExchangeName = key
                self?.exchangePairList = self?.searchExchangePairsResultDic![key] as! [SearchExchangePairContentStruct]
                self?.table.reloadSections([1], with: UITableViewRowAnimation.fade)
            }
            
            cell.contentView.addSubview(exchangeHeader)
            return cell
        }
        let cell:MarketsSearchResultCell = tableView.dequeueReusableCell(withIdentifier: "MarketsSearchResultCell") as! MarketsSearchResultCell
        let model:SearchExchangePairContentStruct = exchangePairList[indexPath.item]
        
        cell.fillDataWithSearchExchangePairsContentStruct(model :model, exchange:selectedExchangeName! )
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let vc:TransactionPairDetailViewController = TransactionPairDetailViewController()
        let symbol:SearchExchangePairContentStruct = self.exchangePairList[indexPath.row]
        
        var model = MarketsCoinPairDataModel.init()
        model.pair = symbol.pair
        model.favorite_status = symbol.favorite_status
        model.icon = symbol.icon
        model.exchange = selectedExchangeName
        let pairStrs = symbol.pair?.components(separatedBy: "/")
        if pairStrs != nil, pairStrs?.count == 2 {
            model.symbol = pairStrs?.first
        }
        vc.coinPair = model
        
        vc.reloadFavoriteStatusClosure = { (status:Int) in
            print("\(status)")
            var symbol = self.exchangePairList[indexPath.row]
            symbol.favorite_status = status
            self.exchangePairList[indexPath.row] = symbol
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        }
        
        
        vc.hidesBottomBarWhenPushed = true
        self.viewController().navigationController?.pushViewController(vc, animated: true)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
