//
//  TotalCostViewController.swift
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/7/31.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class TotalCostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TotalCostCellDelegate {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var hintLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var walletModel: SwiftWalletModel?
    var cellArray: [TotalCostCell] = []
    var totalCost = Decimal() {
        didSet {
            self.amountLbl.text = SwiftExchanger.shared.currencySymbol + SwiftExchanger.shared.getRoundedNumberString(numberString: totalCost.description, decimalCount: 2)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_SetTotalCost_Page)
        self.setUpViews()
    }
    
    private func setUpViews() {
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(endEditing)))
        
        self.titleLbl.text = SWLocalizedString(key: "total_cost")
        self.hintLbl.text = SWLocalizedString(key: "wallet_cost_tip")
        self.totalLbl.text = SWLocalizedString(key: "total") + ":"
        self.confirmBtn.setTitle(SWLocalizedString(key: "wallet_confirm"), for: .normal)
        self.confirmBtn.setBackgroundImage(UIImage.init(color: UIColor.init(hexColor: "dddddd")), for: .selected)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
    }
    
    func costCellDidEndEditing(cell: TotalCostCell) {
        self.calculateTempTotalCost()
        self.configureConfirmButtonEnable()
    }
    
    private func calculateTempTotalCost() {
        var cost = Decimal()
        for cell in self.cellArray {
            if let text = cell.amountField.text,
                let decim = Decimal(string: text)
            {
                cost += decim
            }
//            if let asset = cell.asset,
//                let all = self.walletModel?.allAssets
//            {
//                cost += SwiftExchanger.shared.calculateSingleCost(asset: asset, all: all)
//            }
        }
        self.totalCost = cost
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.cellArray.removeAll()
        if self.walletModel?.coinType == CoinType.BTC {
            return 1
        } else if self.walletModel?.coinType == CoinType.ETH {
            return self.walletModel?.assetsType?.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.init(white: 0.96, alpha: 1)
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = Bundle.main.loadNibNamed("TotalCostCell", owner: nil, options: nil)?.first as? TotalCostCell,
            let wallet = self.walletModel
        {
            cell.costDelegate = self
            cell.setContent(wallet: wallet, assetIndex: indexPath.section)
            self.cellArray.append(cell)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.walletModel?.assetsType?.count == indexPath.section + 1 {
            self.calculateTempTotalCost()
            self.configureConfirmButtonEnable()
        }
    }
    
    private func configureConfirmButtonEnable() {
        var isEnable = false
        for cell in self.cellArray {
            if let text = cell.amountField.text,
                text.count > 0
            {
                isEnable = true
            }
        }
        self.enableConfirmButton(isEnable: isEnable)
    }
    
    private func enableConfirmButton(isEnable: Bool) {
        if isEnable {
            self.confirmBtn.isSelected = false
            self.confirmBtn.isUserInteractionEnabled = true
        } else {
            self.confirmBtn.isSelected = true
            self.confirmBtn.isUserInteractionEnabled = false
        }
    }
    
    @objc private func endEditing() {
        self.view.endEditing(true)
    }

    @IBAction func confirmTapped(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Confirm_SetTotalCost_Page)
        for cell in self.cellArray {
            if self.walletModel?.assetsType != nil,
                let index = cell.assetIndex,
                let asset = cell.asset
            {
                self.walletModel?.assetsType![index] = asset
            }
        }
        if SwiftWalletManager.shared.storeWalletArr() {
            NotificationCenter.post(customeNotification: SWNotificationName.costPriceChange)
            self.noticeOnlyText(SWLocalizedString(key: "price_saved"))
            self.navigationController?.popViewController(animated: true)
        } else {
            self.noticeOnlyText(SWLocalizedString(key: "unknown_error"))
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_SetTotalCost_Page)
        self.navigationController?.popViewController(animated: true)
    }
}
