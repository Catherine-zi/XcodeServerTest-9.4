//
//  RateUsView.swift
//  SwiftWallet
//
//  Created by Selin on 2018/6/29.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class RateUsView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    var score: Int?
    var confirmRateBlock:(()->())?

	@IBOutlet weak var cornerView: SWCornerRadiusView!
	override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Do any additional setup after loading the view.
        //        let tap:UIGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tap(ges:)))
        
        let tap:UIGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(removeMyViewController(tap:)))
        self.addGestureRecognizer(tap)
		
		self.nextBtn.layer.cornerRadius = 4.0
		self.nextBtn.layer.masksToBounds = true
        self.titleLabel.text = SWLocalizedString(key: "rate_us")
        self.nextBtn.setTitle(SWLocalizedString(key: "go_now"), for: .normal)
		
		let cornerTap:UIGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(cornerViewClick(tap:)))
		cornerView.addGestureRecognizer(cornerTap)
    }
    
    @IBAction func starButtonClick(_ sender: UIButton) {
        
        for i in 100...104 {
            let subView:UIButton = self.viewWithTag(i)! as! UIButton
            subView.isSelected = i <= sender.tag ? true : false
            
            if sender.tag == 104 {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Rate_Fivestar)
            } else {
                SPUserEventsManager.shared.trackEventAction(SWUEC_Rate_Threestar, eventPrame: String(i-99).appending("star"))
            }
        }
      score = sender.tag - 100
    }
    @IBAction func rateButtonClick(_ sender: UIButton) {
        self.removeFromSuperview()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_GoRate_Popup)
        if score! > 2 {
			if let url = URL.init(string: String.init(format: "http://itunes.apple.com/us/app/id%@", APPStore_SWAPPID)){
				 UIApplication.shared.openURL(url)
			}
        } else {
            if confirmRateBlock != nil {
                confirmRateBlock!()
            }
        }
    }
    
    @objc func removeMyViewController(tap: UIGestureRecognizer) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Close_Asscore_Popup)
        self.removeFromSuperview()

    }
	@objc func cornerViewClick(tap: UIGestureRecognizer){
		
	}
}
