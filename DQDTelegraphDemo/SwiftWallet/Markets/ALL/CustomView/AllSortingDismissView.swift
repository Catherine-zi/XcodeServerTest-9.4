//
//  TouchPassingView.swift
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/9/6.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class AllSortingDismissView: UIView {
    
    var exceptFrame: CGRect?

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let frame = exceptFrame {
            if frame.contains(point) {
                return true
            }
        }
        NotificationCenter.post(customeNotification: SWNotificationName.dismissAllSortingView)
        return false
    }

}
