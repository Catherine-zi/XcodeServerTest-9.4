//
//  GenerateQRCodeViewController.swift
//  SwiftWallet
//
//  Created by Selin on 2018/3/22.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import CoreImage
import PKHUD

class GenerateQRCodeViewController: UIViewController {

    var walletAddress: String? {
        didSet {
            if walletAddress != nil {
                self.walletAddressLabel.text = walletAddress
                self.generateQRCodeWithWalletAddress()
            }
        }
    }

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var copyBtn: UIButton!
    
    @IBOutlet weak var receivingCodeLabel: UILabel!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_ReceivingCode_Page)
        
        self.setUpUI()
		
//        self.generateQRCodeWithWalletAddress()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpUI() {
        self.receivingCodeLabel.text = SWLocalizedString(key: "receiver_address")
        self.copyBtn.setTitle("  " + SWLocalizedString(key: "wallet_copy_address") + "  ", for: .normal)
//        self.bgView.layer.cornerRadius = 4
//        self.bgView.layer.shadowColor = UIColor.init(red: 30/255.0, green: 89/255.0, blue: 245/255.0, alpha: 0.3).cgColor
//        self.bgView.layer.shadowOffset = CGSize.init(width: 5, height: 10)
       
//        self.copyBtn.layer.cornerRadius = 4
        self.copyBtn.layer.borderColor = UIColor.white.cgColor
        self.copyBtn.layer.borderWidth = 2
        self.copyBtn.sizeToFit()
//        self.qrCodeImageView.layer.cornerRadius = 4

    }
    
    @IBAction func closeButtonClick(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Close_ReceivingCode_Page)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonClick(_ sender: UIButton) {
        
    }
    
    @IBAction func copyAddressButtonClick(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_CopyAddress_ReceivingCode_Page)
        let paste = UIPasteboard.general
        paste.string = self.walletAddressLabel.text
        self.noticeOnlyText(SWLocalizedString(key: "copy_success"))
//        print(paste.string)
        
    }
    
    
    func generateQRCodeWithWalletAddress()  {
        
        guard let walletAddressStr = self.walletAddress else {
            return
        }
        //将信息生成二维码
        //1.创建滤镜
        let fileter = CIFilter.init(name: "CIQRCodeGenerator")
        //2.给滤镜设置内容
        let addressData = walletAddressStr.data(using: String.Encoding.utf8)
        guard addressData != nil else {
            return
        }
        fileter?.setValue(addressData, forKey: "inputMessage")
        //获取生成的二维码
        guard let outPutImage = fileter?.outputImage else {
            return
        }
        //显示二维码,因为outPutImage为CIImage类型,所以要转成UIImage
        let image = self.createHDQRImage(originalImage: outPutImage)
        
        self.qrCodeImageView.image = image
    }
    
    
   //定义方法和要传入的参数,返回值为UIImage
    private func createHDQRImage(originalImage: CIImage) -> UIImage {
        
        let scale = self.qrCodeImageView.bounds.width / originalImage.extent.width
        
        let transform = CGAffineTransform.init(scaleX: scale, y: scale)
         //放大图片
        let hdImage = originalImage.transformed(by: transform)
        
        return UIImage.init(ciImage: hdImage)
        
    }

}

