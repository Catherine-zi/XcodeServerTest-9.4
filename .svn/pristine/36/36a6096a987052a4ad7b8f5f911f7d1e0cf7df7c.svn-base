//
//  ImageProcessor.swift
//  SwiftWallet
//
//  Created by Selin on 2018/4/2.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

public class ImageProcessor: NSObject {
    //保存原始图片
    var image:UIImage?
    
    lazy var context: CIContext = {
        return CIContext(options: nil)
    }()
    
    //初始化
    public init(image:UIImage?) {
        self.image = image
    }
    
    //返回像素化后的图片
    public func pixellated(scale:Int = 30) -> UIImage? {
        if image == nil {
            return nil
        }
        //使用像素化滤镜
        let filter = CIFilter(name: "CIPixellate")!
        let inputImage = CIImage(image: image!)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        //设置像素版半径，值越大马赛克就越大
        filter.setValue(scale, forKey: kCIInputScaleKey)
        let fullPixellatedImage = filter.outputImage
        
        let cgImage = context.createCGImage(fullPixellatedImage!,
                                            from: fullPixellatedImage!.extent)
        return UIImage(cgImage: cgImage!)
    }
    
    //返回高斯模糊后的图片
    public func blured(radius:Int = 40) -> UIImage? {
        if image == nil {
            return nil
        }
        //使用高斯模糊滤镜
        let filter = CIFilter(name: "CIGaussianBlur")!
        let inputImage = CIImage(image: image!)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        //设置模糊半径值（越大越模糊）
//        filter.setValue(radius, forKey: kCIInputRadiusKey)
        let outputCIImage = filter.outputImage
        let rect = CGRect(origin: CGPoint.zero, size: image!.size)
        let cgImage = context.createCGImage(outputCIImage!, from: rect)
        return UIImage(cgImage: cgImage!)
    }
    
//    //截屏
//    public func screenSnapshot(save: Bool) -> UIImage? {
//        guard let window = UIApplication.shared.keyWindow else {
//            return nil
//        }
//        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0)
//        window.layer.render(in: UIGraphicsGetCurrentContext()!)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        if save {
//            UIImageWriteToSavedPhotosAlbum(image!, self, nil, nil)
//        }
//        return image
//    }
}

