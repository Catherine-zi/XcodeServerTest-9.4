//
//  WalletRefreshControl.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/14.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class WalletRefreshControl: UIRefreshControl, UIScrollViewDelegate {

    weak var scrollView:UIScrollView? {
        willSet {
            if newValue == nil {
                scrollView?.removeObserver(self, forKeyPath: "contentOffset")
            }
        }
        didSet {
            scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        }
    }
    typealias RefreshBlock = (WalletRefreshControl) -> ()
    var refreshBlock:RefreshBlock?
    var imgView:UIImageView?
    
    override init() {
        super.init()
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.frame = CGRect.init(x: 0, y: 0, width: SWScreen_width, height: 60)
        self.tintColor = UIColor.blue
        self.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
//        self.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.touchDragOutside)
        self.imgView = UIImageView()
        self.imgView!.image = UIImage.init(named: "iconwaiting")
        self.addSubview(self.imgView!)
        self.imgView!.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
            make.centerX.equalToSuperview()
            make.width.equalTo(self.imgView!.snp.height)
        }
    }
    
    @objc func refresh(control: WalletRefreshControl, event: UIEvent) {
        if self.refreshBlock != nil {
            weak var weakSelf = self
            self.refreshBlock!(weakSelf!)
        }
    }
    
    override func beginRefreshing() {
        super.beginRefreshing()
    }
    
    override func endRefreshing() {
        super.endRefreshing()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            let offset = self.scrollView!.contentOffset.y
            if offset < 0 {
                self.imgView?.transform = CGAffineTransform.init(rotationAngle: 0.1 * offset)
            }
        }
    }
    
    deinit {
        scrollView?.removeObserver(self, forKeyPath: "contentOffset")
    }

}
