//
//  MarketTitleHeaderView.swift
//  DQDTelegraphDemo
//
//  Created by AVAZU on 2018/8/8.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class MarketTitleHeaderView: UIView {

//    typealias AddBtnActionBlock = (()->())
//    var  addBtnActionBlock:AddBtnActionBlock?
    var addBtn:UIButton = UIButton()
    
    typealias ItemSelectedActionBlock = ((Int)->())
    var itemSelectedActionBlock:ItemSelectedActionBlock?
    
    private var lastIndex: Int?
    private var scrollView: UIScrollView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hexColor: "f2f2f2")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadView(titles:[String],  itemWidth: CGFloat) {
        if titles.count == 0 {
            print("titles为空")
            return
        }
        
        scrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width-50, height: self.frame.size.height-1))
        self.addSubview(scrollView!)
        
//        let line: UIView = UIView.init(frame: CGRect.init(x: 0, y: self.frame.size.height-1, width: self.frame.size.width, height: 0.8))
//        line.backgroundColor = UIColor.init(hexColor: "f2f2f2")
//        self.addSubview(line)
        
        let buttonWidth: CGFloat = itemWidth > 0 ? itemWidth : 80
        let buttonHeight: CGFloat = 21
        
        for (index, title) in titles.enumerated() {
            
            let button: UIButton = UIButton.init(type: .custom)
            button.frame = CGRect.init(x: 10 + CGFloat(index)*(buttonWidth+10), y: (scrollView!.frame.size.height-21)/2, width: buttonWidth, height: buttonHeight)
            button.layer.cornerRadius = 3
            button.layer.masksToBounds = true
            
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.setTitleColor(UIColor.white, for: .selected)
            button.setTitleColor(UIColor.init(hexColor: "bbbbbb"), for: .normal)
            button.setBackgroundImage(UIImage.init(color: UIColor.init(hexColor: "1e59f5")), for: .selected)
            button.setBackgroundImage(UIImage.init(color: UIColor.init(hexColor: "f2f2f2")), for: .normal)
            scrollView!.addSubview(button)
            button.tag = index + 100
            button.addTarget(self, action: #selector(buttonAction(btn:)), for: .touchUpInside)
           
            if index == 0 {
                button.isSelected = true
            }
            
            if title == titles.last {
                lastIndex = button.tag
            }
        }
        scrollView!.showsHorizontalScrollIndicator = false
        scrollView!.contentSize = CGSize.init(width: 10 + CGFloat(titles.count)*(buttonWidth+10), height: buttonHeight)
       
        addBtn = UIButton.init(frame: CGRect.init(x: self.frame.size.width-50, y: 0, width: 50, height: self.frame.size.height))
        addBtn.setTitle("+", for: .normal)
        addBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        addBtn.setTitleColor(UIColor.init(hexColor: "bbbbbb"), for: .normal)
        self.addSubview(addBtn)
    }
    

    @objc func buttonAction(btn: UIButton) {
        let width: CGFloat = self.frame.size.width
        let x: CGFloat = btn.frame.origin.x + btn.frame.size.width
        let contentSize_w = (scrollView?.contentSize.width)!-width/2
        
        if x > width/2 && x < contentSize_w {
            scrollView?.setContentOffset(CGPoint.init(x: x-width/2, y: 0), animated: true)
        }
        
        for i in 100...lastIndex! {
            let button:UIButton = self.viewWithTag(i) as! UIButton
            button.isSelected = btn.tag == button.tag ? true : false
        }
        
        if itemSelectedActionBlock != nil {
            itemSelectedActionBlock?(btn.tag)
        }
    }
}
