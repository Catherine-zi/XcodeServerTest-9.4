//
//  TransactionDetailViewController.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/13.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import EthereumKit

class TransactionDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var type:CoinType?
    var walletModel:SwiftWalletModel?
    var cellArr:[[[String:String]]] = [[[:]]]
    var transactionModel:UniversalTransactionModel? {
        didSet {
            self.fee = transactionModel?.fee
        }
    }
    var fee:String? {
        didSet {
            if self.transactionModel != nil {
                let feePrefix = fee?.prefix(10) ?? "--"
                self.cellArr = [
                    [
                        ["title":SWLocalizedString(key: "trade_number"),"accType":"id","accText":self.transactionModel!.ID ?? ""]
                    ],
                    [
                        ["title":SWLocalizedString(key: "mining_fee"),"accType":"text","accText":String(feePrefix) + " " + (self.transactionModel!.coinType?.rawValue ?? "")],
                        ["title":SWLocalizedString(key: "block"),"accType":"text","accText":self.transactionModel!.blockHeight ?? ""]
                    ]
                ]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_TransactionRecordDetail_Page)
        if let state = self.transactionModel?.state {
            SPUserEventsManager.shared.trackEventAction(SWUEC_Show_Trade_State, eventPrame: String(state))
        }

        if self.transactionModel?.coinType == CoinType.ETH {
            self.getRealGas()
        }
        self.setUpViews()
    }
    
    private func setUpViews() {
        
        self.titleLbl.text = SWLocalizedString(key: "transaction_records")
        if self.transactionModel == nil {
            return
        }
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.init(hexColor: "f2f2f2")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70
        self.tableView.register(UINib.init(nibName: "TransactionDetailHeaderCell", bundle: nil), forCellReuseIdentifier: "header")
        self.tableView.register(UINib.init(nibName: "TransactionAddress", bundle: nil), forCellReuseIdentifier: "address")
        self.tableView.register(TransactionDetailCell.classForCoder(), forCellReuseIdentifier: "detail")
    }
    
    private func getRealGas () {
        self.fee = "--"
        guard let txId = self.transactionModel?.ID else {
            return
        }
        EthAPIProvider.request(EthAPI.ethTransactionReceiptHash(txId)) { [weak self] (result) in
            switch result {
            case let .success(response):
                let json = try? JSONDecoder().decode(EthTransactionReceiptModel.self, from: response.data)
                if json?.errcode != 0 {
                    print("get gas error:\n" + (json?.msg ?? ""))
                    return
                }
                guard let gasUsed = json?.data.gasUsed else {
                    return
                }
                if gasUsed.count == 0 {
                    return
                }
                var gas:UInt64 = 0
                let scanner = Scanner(string: gasUsed)
                print(scanner.scanHexInt64(&gas))
                guard let price = self?.transactionModel?.gasPrice else {
                    return
                }
                guard let gasPrice = Decimal.init(string: price),
                let wei = Wei.init((Decimal.init(gas) * gasPrice).description),
                let fee = try? Converter.toEther(wei: wei)
                    else {
                    return
                }
                
                self?.fee = fee.description
                self?.tableView.reloadData()
            case let.failure(error):
                print("get gas net error:\n\(error)")
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + self.cellArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return self.cellArr[section - 1].count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 15
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.init(hexColor: "f2f2f2")
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell: TransactionDetailHeaderCell = tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath) as! TransactionDetailHeaderCell
                cell.setContent(data:self.transactionModel!)
                return cell
            case 1:
                let cell: TransactionDetailAddressCell = tableView.dequeueReusableCell(withIdentifier: "address", for: indexPath) as! TransactionDetailAddressCell
                cell.setContent(from:(self.transactionModel?.from ?? ""), to:(self.transactionModel?.to ?? ""))
                return cell
            default:
                print("default")
            }
        } else {
            let cell:TransactionDetailCell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath) as! TransactionDetailCell
            if self.cellArr[indexPath.section - 1].count == 1 {
                cell.configureType(type: TransactionDetailCell.TransactionDetailCellPositionType.TransactionDetailCellPositionAlone)
            } else if indexPath.row == 0 {
                cell.configureType(type: TransactionDetailCell.TransactionDetailCellPositionType.TransactionDetailCellPositionTop)
            } else if indexPath.row == self.cellArr[indexPath.section - 1].count - 1 {
                cell.configureType(type: TransactionDetailCell.TransactionDetailCellPositionType.TransactionDetailCellPositionBottom)
            } else {
                cell.configureType(type: TransactionDetailCell.TransactionDetailCellPositionType.TransactionDetailCellPositionMiddle)
            }
            cell.configureContent(data: self.cellArr[indexPath.section - 1][indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > 0 {
            let data = self.cellArr[indexPath.section - 1][indexPath.row]
            if data["title"] == SWLocalizedString(key: "trade_number") {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_TradeNumber)
                let webVC = WebViewController()
                if self.type == CoinType.BTC {
                    var url = ""
                    if SwiftWalletManager.isTest {
                        url = "https://live.blockcypher.com/btc-testnet/tx/"
                    } else {
                        url = "https://blockchain.info/tx/"
                    }
                    webVC.urlStr = url + (self.transactionModel?.ID ?? "")
                } else if self.type == CoinType.ETH {
                    var url = ""
                    if SwiftWalletManager.isTest {
                        url = "https://kovan.etherscan.io/tx/"
                    } else {
                        url = "https://etherscan.io/tx/"
                    }
                    webVC.urlStr = url + (self.transactionModel?.ID ?? "")
                }
                self.navigationController?.pushViewController(webVC, animated: true)
            }
        }
    }

    @IBAction func backTapped(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_TransactionRecordDetail_Page)
        self.navigationController?.popViewController(animated: true)
    }
}
