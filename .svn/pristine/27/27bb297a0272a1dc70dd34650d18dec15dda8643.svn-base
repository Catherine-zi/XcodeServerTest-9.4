//
//  CreateWalletViewController.swift
//  SwiftWallet
//
//  Created by Selin on 2018/3/20.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class CreateWalletViewController: UIViewController {
    @IBOutlet weak var watchButton: UIButton!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var noAssetsLbl: UILabel!
    @IBOutlet weak var noAssetsHintLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_NoAssets_Page)
        
        // Do any additional setup after loading the view.
        self.watchButton.setTitle(SWLocalizedString(key: "assets_watch_text"), for: .normal)
        self.importButton.setTitle(SWLocalizedString(key: "assets_import_text"), for: .normal)
        self.createButton.setTitle(SWLocalizedString(key: "assets_create_text") + " >>>", for: .normal)
        self.noAssetsLbl.text = SWLocalizedString(key: "assets_no_assets_text")
        self.noAssetsHintLbl.text = SWLocalizedString(key: "assets_no_assets_hint_text")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func importButtonClick(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_ImportWallet_NoAssets_Page)
		let iwVc:ImportWalletViewController = ImportWalletViewController()
		iwVc.hidesBottomBarWhenPushed = true
		self.navigationController?.pushViewController(iwVc, animated: true)
    }
    @IBAction func createButtonClick(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_CreateWallet_NoAssets_Page)
		let cwVc:CreateWalletDetailViewController = CreateWalletDetailViewController()
		cwVc.hidesBottomBarWhenPushed = true
		self.navigationController?.pushViewController(cwVc, animated: true)
    }
    @IBAction func watchButtonClick(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_WatchWallet_NoAssets_Page)
        let wwVc:WatchWalletViewController = WatchWalletViewController()
        wwVc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(wwVc, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
}
