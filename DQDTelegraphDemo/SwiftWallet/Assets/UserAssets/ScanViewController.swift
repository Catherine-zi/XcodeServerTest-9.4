//
//  ScanViewController.swift
//  DQDTelegraphDemo
//
//  Created by Jack on 2018/7/4.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

typealias ScanCompleteBlock = (String) -> ()

class ScanViewController: LBXScanViewController {
    
//    var scanView: UIView?
    var completeBlock: ScanCompleteBlock?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpStyle()
//        setUpScan()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpViews()
//        UIView.animate(withDuration: 0.3) {
//            self.scanView?.alpha = 1
//        }
    }
    
    private func setUpStyle() {
        //设置扫码区域参数
        var style = LBXScanViewStyle()
//        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_light_green")
        
        style.centerUpOffset = 44;
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.On;
        style.photoframeLineW = 6;
        style.photoframeAngleW = 24;
        style.photoframeAngleH = 24;
        style.isNeedShowRetangle = true;
        
        style.anmiationStyle = LBXScanViewAnimationStyle.NetGrid;
        
        
        //使用的支付宝里面网格图片
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_part_net");
        
        self.scanStyle = style
        
    }
    
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        
        for result:LBXScanResult in arrayResult
        {
            if let str = result.strScanned {
                print(str)
            }
        }
        
        let result:LBXScanResult = arrayResult[0]
        
        if self.completeBlock != nil && result.strScanned != nil {
            self.completeBlock!(result.strScanned!)
        }
        self.back()
    }
    
    private func setUpViews() {
        let closeBtn = UIButton()
        closeBtn.setTitle("Close", for: .normal)
        closeBtn.setBackgroundImage(UIImage.init(color: UIColor.init(hexColor: "1e59f5")), for: .normal)
        closeBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.view?.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(50)
        }
    }
    
//    private func setUpScan(){
//        self.view.backgroundColor = UIColor.black
//        weak var weakSelf = self
//        self.scanView = UIView()
//        self.scanView?.alpha = 0
//        self.scanView?.backgroundColor = UIColor.black
//        let scan = BTCQRCode.scannerView { (address) in
//            if address != nil {
//                weakSelf?.dealScanView(scanText: address!)
//            }
//        }
//        if scan == nil {
//            return
//        }
//        scanView?.addSubview(scan!)
//        scan!.snp.makeConstraints { (make) in
//            make.edges.equalTo(0)
//        }
//
//        self.view.addSubview(scanView!)
//        scanView!.snp.makeConstraints { (make) in
//            make.edges.equalTo(0)
//        }
//
//        let closeBtn = UIButton()
//        closeBtn.setTitle("Close", for: .normal)
//        closeBtn.setBackgroundImage(UIImage.init(color: UIColor.init(hexColor: "1e59f5")), for: .normal)
//        closeBtn.addTarget(weakSelf, action: #selector(back), for: .touchUpInside)
//        self.view?.addSubview(closeBtn)
//        closeBtn.snp.makeConstraints { (make) in
//            make.left.right.bottom.equalTo(0)
//            make.height.equalTo(50)
//        }
//    }
//
//    private func getStyleLayer() {
//        let layer = CALayer()
//
//    }
//
//    private func dealScanView(scanText: String) {
//        let sendVC = TransferAccountsViewController.init(nibName: "TransferAccountsViewController", bundle: nil)
////        var controllers = self.navigationController?.viewControllers
//        sendVC.destinationAddress = scanText
//        self.present(sendVC, animated: true) {
//            self.navigationController?.popViewController(animated: false)
//        }
//    }
    
    @objc private func back() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
