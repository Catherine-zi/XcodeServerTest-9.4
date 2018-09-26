//
//  TestSettingViewController.swift
//  DQDTelegraphDemo
//
//  Created by Jack on 2018/7/2.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class TestSettingViewController: UIViewController {
    
    let testApiKey = "TestAPIKey"
    let testWalletKey = "TestWalletKey"
    
    @IBOutlet weak var testApiSwitch: UISwitch!
    @IBOutlet weak var testWalletSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setTestValues()
    }
    
    private func setTestValues() {
        let isTestApi = UserDefaults.standard.bool(forKey: testApiKey)
        let isTestWallet = UserDefaults.standard.bool(forKey: testWalletKey)
        self.testApiSwitch.isOn = isTestApi
        self.testWalletSwitch.isOn = isTestWallet
    }

    @IBAction func testApiTapped(_ sender: Any) {
        let isTestApi = self.testApiSwitch.isOn
        isTest = isTestApi
        UserDefaults.standard.set(isTestApi, forKey: testApiKey)
        let tabVC: SWTabBarController = self.navigationController?.tabBarController as! SWTabBarController
        tabVC.resetTabbarController()
    }
    @IBAction func testWalletTapped(_ sender: Any) {
        let isTestWallet = self.testWalletSwitch.isOn
        SwiftWalletManager.isTest = isTestWallet
        UserDefaults.standard.set(isTestWallet, forKey: testWalletKey)
//        let tabVC: SWTabBarController = self.navigationController?.tabBarController as! SWTabBarController
//        tabVC.resetTabbarController()
    }
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
