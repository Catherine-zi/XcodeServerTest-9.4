//
//  MoreViewController.swift
//  SwiftWallet
//
//  Created by Selin on 2018/5/4.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {

    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var title3Label: UILabel!
    @IBOutlet weak var content1Label: UILabel!
    @IBOutlet weak var content2Label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title1Label.text = NSLocalizedString("What is Telegram?", comment: "")
        self.title2Label.text = NSLocalizedString("What is the difference?", comment: "")
        self.title3Label.text = NSLocalizedString("Please log in, Your registered account can also be used in telegram.", comment: "")
        self.content1Label.text = NSLocalizedString("Telegram is the fast messaging app on the market. People in many countries use it to share digital currency information in groups.", comment: "")
        self.content2Label.text = NSLocalizedString("We took advantage of Telegram legally and made some improvements:\n1、Our app offer you many high quality groups to know digital currencies.\n2、Many new features will be added later.", comment: "")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func backButtonClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
