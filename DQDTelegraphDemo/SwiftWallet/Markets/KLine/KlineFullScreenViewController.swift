//
//  KlineFullScreenViewController.swift
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/9/10.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit
import HSStockChart
class KlineFullScreenViewController: UIViewController {

	var exchangeName:String?
	var transactionPairTitle:String?
	var dataK:[HSKLineModel]?
	var klineType: HSChartType?
	var currentTimeType: String?
    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = UIColor.init(hexColor: "F2F2F2")
		
		
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
//		guard let tabBar:SWTabBarController = UIApplication.shared.keyWindow?.rootViewController as? SWTabBarController else {
//			return
//		}
//		tabBar.allowRotation = true
//		
//		let value = UIInterfaceOrientation.landscapeLeft.rawValue
//		UIDevice.current.setValue(value, forKey: "orientation")
	}
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		let topMargin:CGFloat = 15
		let kLine = KLineView.init(frame: CGRect(x: 0, y: topMargin, width: SWScreen_height - SWStatusBarH, height: SWScreen_width - topMargin * 2), isFullScreen: true, exchangeName: exchangeName, transactionPairTitle: transactionPairTitle,klineType: klineType ?? .kLineForDay,currentTimeType: currentTimeType ?? "1h")
		kLine.backgroundColor = view.backgroundColor
		
		self.view.addSubview(kLine)
		
		if let models = dataK {
			kLine.stockChartView.kLineType = klineType
			kLine.stockChartView.configureView(data: models, isLoadMore: false)
			kLine.stockChartView.isHidden = false
		}
		
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override var shouldAutorotate: Bool {
		return true
	}

}
