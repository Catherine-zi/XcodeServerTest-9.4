//
//  SearchCoinListViewController.swift
//  DQDTelegraphDemo
//
//  Created by AVAZU on 2018/8/7.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class SearchCoinListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    private var coinList:[SearchMarketContentStruct] = []
    var searchKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib.init(nibName: "MarketsSearchResultCell", bundle: nil), forCellReuseIdentifier: "MarketsSearchResultCell")
        
        self.searchCoinRequest(keyword: self.searchKey!, pageNo: 0)

        tableView.mj_header = SwiftDiyHeader(refreshingBlock: {
            self.searchCoinRequest(keyword: self.searchKey!, pageNo: 0)
        })
        tableView.mj_footer = MJRefreshAutoFooter.init(refreshingBlock: {
            self.searchCoinRequest(keyword: self.searchKey!, pageNo: self.coinList.count)

        })
    }

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //搜索币种接口
    private func searchCoinRequest(keyword: String, pageNo: Int) {
        SearchAPIProvider.request(SearchAPI.searchSymbol(keyword, pageNo, 20)) { [weak self](result) in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()
            
            if case let .success(response) = result {
                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(SearchMarketStruct.self, from: decryptedData)
                if json?.code != 0 {
                    if json?.msg != nil {
                        self?.noticeOnlyText(json!.msg!)
                    }
                    return
                }
                DispatchQueue.main.async {
                    if pageNo == 0 {
                        self?.coinList.removeAll()
                    } else if json?.data?.count == 0 {
                        self?.tableView.mj_footer.state = MJRefreshState.noMoreData
                        self?.noticeOnlyText(SWLocalizedString(key: "load_end"))
                        return
                    }
                    for symbol:SearchMarketContentStruct in (json?.data)! {
                        self?.coinList.append(symbol)
                    }
                    self?.tableView.reloadData()
                }
            } else {
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MarketsSearchResultCell = tableView.dequeueReusableCell(withIdentifier: "MarketsSearchResultCell") as! MarketsSearchResultCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let model:SearchMarketContentStruct = coinList[indexPath.item]
        cell.fillDataWithSearchMarketContentStruct(modelContentStruct: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc:AllDetailViewController = AllDetailViewController()
        let model:SearchMarketContentStruct = coinList[indexPath.item]
        vc.symbolName = model.symbol
        vc.symbolIconUrl = model.icon
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
   

}
