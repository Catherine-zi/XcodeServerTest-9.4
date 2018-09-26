//
//  ChangeCurrencyViewController.swift
//  DQDTelegraphDemo
//
//  Created by AVAZU on 2018/6/29.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

struct CurrencyModel:Codable {
    
    var currency:String
    var currencyCode:String
    var state:Bool
}
class ChangeCurrencyViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!

    var currencyModels:[CurrencyModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.loadUI()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        self.view.addSubview(blurView)
        self.view.bringSubview(toFront: bgView)
    }
    
    func loadUI() {
        self.titleLabel.text = SWLocalizedString(key: "currency_unit")
        self.saveBtn.setTitle(SWLocalizedString(key: "setting_dialog_save"), for: .normal)
       
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView.init()
        tableView.register(UINib.init(nibName: "CurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "CurrencyTableViewCell")
        let currencyArray = ["CNY","USD","KRW","EUR","JPY","RUB"]
        let currencyCodes = ["CNY","USD","KRW","EUR","JPY","RUB"]
//        let languageCodes = [CurrentLanguage.English.rawValue,CurrentLanguage.Chinese_Hans.rawValue,CurrentLanguage.Chinese_Hant.rawValue,CurrentLanguage.Japanese.rawValue,CurrentLanguage.Korean.rawValue,CurrentLanguage.Russian.rawValue]

        let currentCurrencyCode:String = UserDefaults.standard.string(forKey: SwiftExchanger.shared.currencyStoreKey)!
        
        for (index, currency) in currencyArray.enumerated() {
            let code: String = currencyCodes[index]
            let state = (code == currentCurrencyCode) ? true : false
            let model:CurrencyModel = CurrencyModel.init(currency: currency, currencyCode: code, state: state)
            currencyModels.append(model)
        }
         DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    @IBAction func closeBtnClick(_ sender: UIButton) {
//        self.view.removeFromSuperview()
        self.dismiss(animated: false, completion: nil)
    }
   
    @IBAction func saveBtnClick(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Save_CuurrencyUnit)

        for item in currencyModels {
            if item.state == false { continue }
            
            UserDefaults.standard.set(item.currencyCode, forKey: SwiftExchanger.shared.currencyStoreKey)
            UserDefaults.standard.synchronize()
            
            SwiftExchanger.shared.currency = SwiftExchanger.SwiftCurrency.init(rawValue: item.currencyCode)!
            
        }
        self.dismiss(animated: false) {
            NotificationCenter.post(customeNotification: SWNotificationName.currencySettingChange)
        }
        
       
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.currencyModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CurrencyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CurrencyTableViewCell") as! CurrencyTableViewCell
        let model = currencyModels[indexPath.row]
        cell.titleBtn.setTitle(model.currency, for: .normal)
        cell.stateBtn.isSelected = model.state
        cell.titleBtn.isSelected = model.state
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if model.state == true {
            cell.titleBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            cell.titleBtn.setTitleColor( .white, for: .selected)
        } else {
            cell.titleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            cell.titleBtn.setTitleColor(UIColor.init(hexColor: "789BF9"), for: .normal)
        }
        if indexPath.row == (currencyModels.count - 1) {
            cell.separator.isHidden = true
        } else {
            cell.separator.isHidden = false
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var model = currencyModels[indexPath.row]
        model.state = true
//        languageModels.insert(model, at: indexPath.row)
        var newModels:[CurrencyModel] = []
        
        for (index,item) in currencyModels.enumerated() {
            let state : Bool = indexPath.row==index ? true : false
            let newModel:CurrencyModel = CurrencyModel.init(currency: item.currency, currencyCode: item.currencyCode, state: state)
            newModels.append(newModel)
        }
        currencyModels.removeAll()
        currencyModels = newModels
        tableView.reloadData()
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: false, completion: nil)
    }
}










