//
//  AlertHistoryViewController.swift
//  DQDTelegraphDemo
//
//  Created by AVAZU on 2018/8/31.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class AlertHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var alertTableView: UITableView!
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!

    private var historyList: [AlertMsgHistoryDataModel] = []


    private lazy var networkFailView: UIView = {
        let failView : NetworkFailView = Bundle.main.loadNibNamed("NetworkFailView", owner: nil, options: nil)?.first as! NetworkFailView
        return failView
    }()
    
    //MARK: - Circle Life

    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Show_AlertHistory_page)
        self.navTitleLabel.text = SWLocalizedString(key: "price_alert_history_title")
        self.noDataLabel.text = SWLocalizedString(key: "price_alert_history_empty")
        alertTableView.estimatedRowHeight = 80
        alertTableView.rowHeight = UITableViewAutomaticDimension
        alertTableView.register(UINib.init(nibName: "AlertHistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "AlertHistoryTableViewCell")
       
        alertTableView.mj_header = SwiftDiyHeader(refreshingBlock: {
            self.requestDataWithAlertHistory(offset: 0)
        })
        
        alertTableView.mj_footer = MJRefreshFooter.init(refreshingBlock: {
            self.requestDataWithAlertHistory(offset: self.historyList.count)
        })
        
        alertTableView.mj_header.beginRefreshing()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Load View
    func loadFailedView() {
        historyList.removeAll()
        alertTableView.reloadData()
        view.addSubview(networkFailView)
        view.bringSubview(toFront: networkFailView)
        networkFailView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    func loadNoDataView() {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Show_Empty_AlertHistory_page)
        noDataView.isHidden = false
        deleteBtn.isHidden = true
    }
    //MARK: - Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Back_AlertHistory_page)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deletAllDataButtonAction(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Click_DeleteAll_AlertHistory_Page)
        let deleteAllView: AlertDeletePopView = Bundle.main.loadNibNamed("AlertDeletePopView", owner: self, options: nil)?.first as! AlertDeletePopView
        deleteAllView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        deleteAllView.frame = view.bounds
        view.addSubview(deleteAllView)
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Show_DeleteAll_Popup_AlertHistory_page)
        
        deleteAllView.ConirmDeleteAlertBlock = {
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Click_confirm_AlertHistory_Page)
            var modelIDs:[Int] = []
            for model in self.historyList {
                modelIDs.append(Int(model.id!)!)
            }
            self.requestNetworkWithDeleteHistory(model_id_Arr: modelIDs)
        }
        deleteAllView.CancelDeleteAlertBlock = {
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Click_cancel_AlertHistory_Page)
        }
    }
    
    //MARK: - Network
    func requestDataWithAlertHistory(offset: Int)  {
        AlertAPIProvider.request(AlertAPI.alert_msg_history(limit: 20, offset: offset)) { [weak self](result)  in
            
            self?.alertTableView.mj_header.endRefreshing()
            self?.alertTableView.mj_footer.endRefreshing()
          

            if case let .success(response) = result {
                let decryptedData:Data = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(AlertMsgHistoryModel.self, from: decryptedData)

                if json?.code != 0 || json?.data == nil {
                    self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
                    print("response json: \(String(describing: json ?? nil))")
                    return
                }

                if offset == 0 && json?.data?.count == 0 {
                    self?.loadNoDataView()
                    return
                }
                if offset == 0 {
                    self?.historyList.removeAll()
                }
                for mode in (json?.data)! {
                    self?.historyList.append(mode)
                }

                DispatchQueue.main.async {
                    
                    self?.networkFailView.removeFromSuperview()
                    self?.noDataView.isHidden = true
                    self?.deleteBtn.isHidden = false
                    self?.alertTableView.reloadData()
                }
            } else {
                self?.loadFailedView()
            }
        }
    }
    
    func requestNetworkWithDeleteHistory(model_id_Arr: [Int]) {
        AlertAPIProvider.request(AlertAPI.alert_msg_delete(id: model_id_Arr)) { [weak self](result) in
            if case let .success(response) = result {
                let decryptedData:Data = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(AlertSetDeleteModel.self, from: decryptedData)
                if json?.code != 0 {
                    print("response json: \(String(describing: json ?? nil))")
                    return
                } else {
                    SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Show_DeleteSuccess_Prompt_AlertHistory_Page)
                    self?.noticeOnlyText(SWLocalizedString(key: "delete_success"))
                    
                    for model_id in model_id_Arr {
                        for (index, model) in (self?.historyList.enumerated())! {
                            if model_id == Int(model.id!) {
                                self?.historyList.remove(at: index)
                            }
                        }
                    }
                    self?.alertTableView.reloadData()
                    if self?.historyList.count == 0 {
                        self?.loadNoDataView()
                    }
                }
            }
        }
    }
    
    //MARK: - Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : AlertHistoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AlertHistoryTableViewCell", for: indexPath) as! AlertHistoryTableViewCell
        let model = historyList[indexPath.row]
        cell.fillDataWithModel(model: model)
        
        cell.longPressActionBlock = { [weak self] in
            
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Show_Delete_Prompt_AlertHistory_page)
            let alertVC : UIAlertController = UIAlertController.init()
            let deleteAction : UIAlertAction = UIAlertAction.init(title: SWLocalizedString(key: "delete_alert"), style: UIAlertActionStyle.destructive, handler: { [weak self](action) in
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Click_Delete_AlertHistory_Page)
                self?.requestNetworkWithDeleteHistory(model_id_Arr: [Int(model.id!)!])
            })
            let cancelAction: UIAlertAction = UIAlertAction.init(title: SWLocalizedString(key: "log_out_bitPub_dialog_cancel"), style: .cancel, handler: nil)
            alertVC.addAction(deleteAction)
            alertVC.addAction(cancelAction)
            self?.present(alertVC, animated: true, completion: nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

       tableView.deselectRow(at: indexPath, animated: true)

    }
	
}
