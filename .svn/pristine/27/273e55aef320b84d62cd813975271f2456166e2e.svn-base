//
//  ChatViewController.swift
//  SwiftWallet
//
//  Created by Jack on 13/03/2018.
//  Copyright © 2018 DotC United Group. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var chatTableView:UITableView = {
        let tableView:UITableView = UITableView.init(frame: CGRect.init(x: 0, y: 64, width: SWScreen_width, height: SWScreen_height-64), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatTableViewCell")
        tableView.rowHeight = 79.0
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Chart_TabBar)//打点

        self.view.addSubview(chatTableView)
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        let telegramUserInfo = TelegramUserInfo.shareInstance
//        if telegramUserInfo.telegramLoginState == "yes" {
//            let chatLoginVC: ChatLoginViewController = ChatLoginViewController()
//            self.navigationController?.pushViewController(chatLoginVC, animated: false)
//            
//        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ChatTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell") as! ChatTableViewCell
        cell.selectionStyle = .none
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "DELETE"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("delete")
        }
    }
}
