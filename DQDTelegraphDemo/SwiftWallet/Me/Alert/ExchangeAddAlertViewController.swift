//
//  ExchangeAddAlertViewController.swift
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/9/4.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

typealias CompleteBlock = () -> ()

class ExchangeAddAlertViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var exchangeNameLbl: UILabel!
    @IBOutlet weak var shadow0: UIView!
    @IBOutlet weak var shadow1: UIView!
    @IBOutlet weak var shadow2: UIView!
    @IBOutlet weak var shadow3: UIView!
    @IBOutlet weak var pairTitleLbl: UILabel!
    @IBOutlet weak var pairLbl: UILabel!
    @IBOutlet weak var priceTitleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var aboveTitleLbl: UILabel!
    @IBOutlet weak var aboveUnitLbl: UILabel!
    @IBOutlet weak var aboveRateField: UITextField!
    @IBOutlet weak var abovePriceField: UITextField!
    @IBOutlet weak var belowTitleLbl: UILabel!
    @IBOutlet weak var belowUnitLbl: UILabel!
    @IBOutlet weak var belowRateField: UITextField!
    @IBOutlet weak var belowPriceField: UITextField!
    @IBOutlet weak var hintLbl: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    
    var alertData: AlertDetailStruct?
    var exchangeName = ""
    var pairName = ""
    var unitName = ""
    var currentPrice: Decimal = Decimal() {
        didSet {
            if self.priceLbl != nil {
                self.priceLbl.text = currentPrice.description + " " + self.unitName
            }
            if let aboveRateField = self.aboveRateField,
                let abovePriceField = self.abovePriceField,
                let belowRateField = self.belowRateField,
                let belowPriceField = self.belowPriceField
            {
                var str = ""
                for (index, char) in self.currentPrice.description.enumerated() {
                    if char != "." {
                        if index == self.currentPrice.description.count - 1 {
                            str.append("1")
                        } else {
                            str.append("0")
                        }
                    } else {
                        str.append(".")
                    }
                }
                if let change = Decimal(string: str) {
                    let rate = change / currentPrice * 100
                    aboveRateField.placeholder = SwiftExchanger.shared.getRoundedNumber(number: rate, decimalCount: 4).description
                    belowRateField.placeholder = SwiftExchanger.shared.getRoundedNumber(number: rate, decimalCount: 4).description
                    abovePriceField.placeholder = (currentPrice + change).description
                    belowPriceField.placeholder = (currentPrice - change).description
                }
            }
        }
    }
    var completeBlock: CompleteBlock?
    var fieldArray: [UITextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_PriceAlert_page)
        
        self.setUpViews()
        self.loadData()
    }
    
    private func setUpViews() {
        
        self.setShadow(view: self.shadow0)
        self.setShadow(view: self.shadow1)
        self.setShadow(view: self.shadow2)
        self.setShadow(view: self.shadow3)
        
        fieldArray = [self.aboveRateField, self.abovePriceField, self.belowRateField, self.belowPriceField]
        
        self.titleLbl.text = SWLocalizedString(key: "price_alert_title")
        self.pairTitleLbl.text = SWLocalizedString(key: "price_alert_pairs")
        self.priceTitleLbl.text = SWLocalizedString(key: "price_alert_current")
        self.aboveTitleLbl.text = SWLocalizedString(key: "price_alert_above")
        self.belowTitleLbl.text = SWLocalizedString(key: "price_alert_below")
        self.hintLbl.text = SWLocalizedString(key: "price_alert_hint_no_price")
        self.doneBtn.setTitle(SWLocalizedString(key: "wallet_done"), for: .normal)
        self.exchangeNameLbl.text = self.exchangeName
        self.pairLbl.text = self.pairName
        if let index = self.pairName.index(of: "/")
        {
            self.unitName = String(self.pairName.suffix(from: self.pairName.index(after: index)))
        }
        self.priceLbl.text = currentPrice.description + " " + self.unitName
        self.aboveUnitLbl.text = self.unitName
        self.belowUnitLbl.text = self.unitName
        
        if self.alertData != nil {
            self.aboveRateField.text = self.removeZero(str: self.alertData?.above_change)
            self.abovePriceField.text = self.removeZero(str: self.alertData?.above_price)
            self.belowRateField.text = self.removeZero(str: self.alertData?.below_change)
            self.belowPriceField.text = self.removeZero(str: self.alertData?.below_price)
        }
        self.updateDoneButtonState(field: self.aboveRateField, text: self.aboveRateField.text ?? "")
        self.updateHintText(field: self.aboveRateField, text: self.aboveRateField.text ?? "")
        
        self.aboveRateField.delegate = self
        self.abovePriceField.delegate = self
        self.belowRateField.delegate = self
        self.belowPriceField.delegate = self
        
        let endEditTap = UITapGestureRecognizer.init(target: self, action: #selector(endEditing))
        self.view.addGestureRecognizer(endEditTap)
        
    }
    
    private func loadData() {
        if exchangeName.count == 0 || pairName.count == 0 {
            return
        }
        MarketsAPIProvider.request(MarketsAPI.markets_exchangePairTicket(exchangeName, pairName)) { [weak self](result) in
            
            guard let strongSelf = self else{
                return
            }
            
            if case let .success(response) = result {
                
                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(ExchangePairTicketStruct.self, from: decryptedData)
                
                DispatchQueue.main.async(execute: {
                    
                    if let pairRightPriceUsd = json?.data?.pairRightPrice,
                        let decimal:Decimal = Decimal(string: pairRightPriceUsd)
                    {
                        strongSelf.currentPrice = decimal
                    }
                })
            }else {
                
            }
        }
    }
    
    private func requestForSetAlert() {
        guard let aboveChange = self.aboveRateField.text,
            let abovePrice = self.abovePriceField.text,
            let belowChange = self.belowRateField.text,
            let belowPrice = self.belowPriceField.text else {
                return
        }
        self.doneBtn.isUserInteractionEnabled = false
        AlertAPIProvider.request(AlertAPI.alert_set(exchange: self.exchangeName, pair: self.pairName, above_change: aboveChange, above_price: abovePrice, below_change: belowChange, below_price: belowPrice, id: self.alertData?.id)) { (result) in
            self.doneBtn.isUserInteractionEnabled = true
            switch result {
            case let .success(response):
                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(AlertSetDeleteModel.self, from: decryptedData)
                if json?.code != 0 {
                    print("alert_set error: \(String(describing: json ?? nil))")
                    self.noticeOnlyText(SWLocalizedString(key: "unknown_error"))
                    return
                }
                self.done()
            case let .failure(error):
                self.noticeOnlyText(SWLocalizedString(key: "network_error"))
                print(error)
            }
        }
    }
    
    func setShadow(view: UIView) {
        view.layer.cornerRadius = 2
        view.layer.shadowRadius = 15
        view.layer.shadowColor = UIColor.init(hexColor: "eeeeee").cgColor
        view.layer.shadowOffset = CGSize.zero//CGSize(width: 0, height: 5)
        view.layer.shadowOpacity = 1
        view.layer.masksToBounds = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str:String = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        self.updateOtherField(field: textField, text: str)
        self.updateHintText(field: textField, text: str)
        self.updateDoneButtonState(field: textField, text: str)
        return true
    }
    
    private func updateOtherField(field: UITextField, text: String) {
        if self.currentPrice == 0 {
            return
        }
        switch field {
        case self.aboveRateField:
            if let rate = Decimal(string: text)
            {
                let price = self.currentPrice * (1 + rate / 100)
                if price > 0 {
                    self.abovePriceField.text = price.description
                } else {
                    self.abovePriceField.text = "0"
                }
            } else {
                self.abovePriceField.text = ""
            }
        case self.abovePriceField:
            if let price = Decimal(string: text)
            {
                let rate = (price - self.currentPrice) / self.currentPrice * 100
                if rate > 0 {
                    self.aboveRateField.text = SwiftExchanger.shared.getRoundedNumber(number: rate, decimalCount: 4).description
                } else {
                    self.aboveRateField.text = "0"
                }
            } else {
                self.aboveRateField.text = ""
            }
        case self.belowRateField:
            if let rate = Decimal(string: text)
            {
                let price = self.currentPrice * (1 - rate / 100)
                if price > 0 {
                    self.belowPriceField.text = price.description
                } else {
                    self.belowPriceField.text = "0"
                }
            } else {
                self.belowPriceField.text = ""
            }
        case self.belowPriceField:
            if let price = Decimal(string: text)
            {
                let rate = (self.currentPrice - price) / self.currentPrice * 100
                if rate > 0 {
                    self.belowRateField.text = SwiftExchanger.shared.getRoundedNumber(number: rate, decimalCount: 4).description
                } else {
                    self.belowRateField.text = "0"
                }
            } else {
                self.belowRateField.text = ""
            }
        default:
            print("")
        }
    }
    
    private func updateHintText(field: UITextField, text: String) {
        var str = ""
        var aboveStr = ""
        var belowStr = ""
        if field == self.abovePriceField {
            aboveStr = text
        } else {
            aboveStr = self.abovePriceField.text ?? ""
        }
        if let abovePrice = Decimal(string: aboveStr),
            abovePrice >= 0
        {
            str += "≥" + SwiftExchanger.shared.getRoundedNumber(number: abovePrice, decimalCount: 4).description
        }
        if field == self.belowPriceField {
            belowStr = text
        } else {
            belowStr = self.belowPriceField.text ?? ""
        }
        if let belowPrice = Decimal(string: belowStr),
            belowPrice >= 0
        {
            if str.count > 0 {
                str += ", "
            }
            str += "≤" + SwiftExchanger.shared.getRoundedNumber(number: belowPrice, decimalCount: 4).description
        }
        if str.count > 0 {
            self.hintLbl.text = String.init(format: SWLocalizedString(key: "price_alert_hint_text"), str)
        } else {
            self.hintLbl.text = SWLocalizedString(key: "price_alert_hint_no_price")
        }
    }
    
    private func updateDoneButtonState(field: UITextField, text: String) {
        for textField in self.fieldArray {
            if textField == field {
                if let decim = Decimal(string: text) {
                    if decim > 0 {
                        self.setDoneButtonStyle(enabled: true)
                        return
                    }
                }
            } else {
                if let str = textField.text,
                    let decim = Decimal(string: str)
                {
                    if decim > 0 {
                        self.setDoneButtonStyle(enabled: true)
                        return
                    }
                }
            }
        }
        self.setDoneButtonStyle(enabled: false)
    }
    
    private func setDoneButtonStyle(enabled: Bool) {
        if enabled {
            self.doneBtn.isUserInteractionEnabled = true
            self.doneBtn.setBackgroundImage(UIImage.init(color: UIColor.init(hexColor: "1e59f5")), for: .normal)
        } else {
            self.doneBtn.isUserInteractionEnabled = false
            self.doneBtn.setBackgroundImage(UIImage.init(color: UIColor.init(hexColor: "dddddd")), for: .normal)
        }
    }
    
    // 去掉0和多余的0
    private func removeZero(str: String?) -> String? {
        var result = str
        if let string = str,
            let decim = Decimal(string: string) {
            if decim == 0 {
                result = ""
            } else {
                result = decim.description
            }
        }
        return result
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Done_PriceAlert_page)
        if let abovePriceStr = self.abovePriceField.text,
            let abovePrice = Decimal(string: abovePriceStr)
        {
            if abovePrice != 0 {
                if abovePrice <= self.currentPrice {
                    self.noticeOnlyText(SWLocalizedString(key: "price_alert_above_false"))
                    SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_AboveError_Prompt_PriceAlert_page)
                    return
                }
            }
        }
        if let belowPriceStr = self.belowPriceField.text,
            let belowPrice = Decimal(string: belowPriceStr)
        {
            if belowPrice != 0 {
                if belowPrice >= self.currentPrice {
                    self.noticeOnlyText(SWLocalizedString(key: "price_alert_below_false"))
                    SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_BelowError_Prompt_PriceAlert_page)
                    return
                }
            }
        }
        self.requestForSetAlert()
    }
    
    private func done() {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_SetSuccess_Prompt_PriceAlert_page)
        self.noticeOnlyText(SWLocalizedString(key: "price_alert_set_successfully"))
        if let block = self.completeBlock {
            block()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_PriceAlert_page)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func endEditing() {
        self.view.endEditing(true)
    }
}
