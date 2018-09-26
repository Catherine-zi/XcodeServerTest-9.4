//
//  SearchExchangeHeaderView.swift
//  DQDTelegraphDemo
//
//  Created by AVAZU on 2018/8/2.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class SearchExchangeHeaderView: UIView {
//    public var titles: [String]?
    typealias ButtonActionBlock = ((Int)->())
    var buttonActionBlock:ButtonActionBlock?
    private var lastIndex: Int?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
//        loadView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func loadView(titles:[String], selectedKey: String?) {
        if titles.count == 0 {
            print("titles为空")
            return
        }
        
        let scrollView : UIScrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height-1))
        self.addSubview(scrollView)
        
        let line: UIView = UIView.init(frame: CGRect.init(x: 0, y: self.frame.size.height-1, width: self.frame.size.width, height: 0.8))
        line.backgroundColor = UIColor.init(hexColor: "f2f2f2")
        self.addSubview(line)
        
        let buttonWidth: CGFloat =  80
        let buttonHeight: CGFloat = 21

        for (index, title) in titles.enumerated() {
            
            let button: UIButton = UIButton.init(type: .custom)
            button.frame = CGRect.init(x: 10 + CGFloat(index)*(buttonWidth+10), y: (scrollView.frame.size.height-21)/2, width: buttonWidth, height: buttonHeight)
            button.layer.cornerRadius = 3
            button.layer.masksToBounds = true
            
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.setTitleColor(UIColor.white, for: .selected)
            button.setTitleColor(UIColor.init(hexColor: "bbbbbb"), for: .normal)
            button.setBackgroundImage(UIImage.init(color: UIColor.init(hexColor: "1e59f5")), for: .selected)
            button.setBackgroundImage(UIImage.init(color: UIColor.white), for: .normal)
            scrollView.addSubview(button)
            button.tag = index + 100
            button.addTarget(self, action: #selector(buttonAction(btn:)), for: .touchUpInside)
            if selectedKey != nil && titles.contains(selectedKey!) == true {
                if title == selectedKey {
                    button.isSelected = true
                }
            } else {
                if index == 0 {
                    button.isSelected = true
                }
            }
           
            if title == titles.last {
                lastIndex = button.tag
            }
        }
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize.init(width: 10 + CGFloat(titles.count)*(buttonWidth+10)+buttonWidth, height: buttonHeight)
        if selectedKey != nil && titles.contains(selectedKey!) == true  {
            let num = titles.index(of: selectedKey!)
            let scrollOrigin_X: CGFloat = (scrollView.frame.size.width-(10 + CGFloat(num!)*(buttonWidth+10)))/2
            scrollView.scrollRectToVisible(CGRect.init(x: scrollOrigin_X, y: (scrollView.frame.size.height-21)/2, width: buttonWidth, height: buttonHeight), animated: true)

        }
    }
    
    @objc func buttonAction(btn: UIButton) {

        for i in 100...lastIndex! {
            let button:UIButton = self.viewWithTag(i) as! UIButton
            button.isSelected = btn.tag == button.tag ? true : false
        }
        
        if buttonActionBlock != nil {
            buttonActionBlock?(btn.tag)
        }
    }
}








