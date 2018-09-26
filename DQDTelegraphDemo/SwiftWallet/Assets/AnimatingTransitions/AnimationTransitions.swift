//
//  AnimationTransitions.swift
//  SwiftWallet
//
//  Created by Selin on 2018/3/29.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//
import UIKit

enum AnimationType {
    case present
    case dismiss
}

enum AnimationPopType {
   case blure
   case blakApha
   case none
}

let blurViewTag: NSInteger = 10240
let blackLayerTag: NSInteger = 10241

class AnimationTransitions: NSObject,UIViewControllerAnimatedTransitioning {
    
     var animationType: AnimationType = .present
     var animationPopType: AnimationPopType = .blakApha
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)

        let fromView = fromViewController?.view
        let toView = toViewController?.view
        
        let container = transitionContext.containerView

        if self.animationType == .present {
            container.addSubview(toView!)
        }
        
        let animationView: UIView = ((self.animationType == .present) ? toView : fromView)!
        let onScreenFrame: CGRect = CGRect.init(x: 0, y: 0, width: SWScreen_width, height: SWScreen_height)
        let offScreenFrame: CGRect = CGRect.init(x: 0, y: onScreenFrame.size.height, width: SWScreen_width, height: SWScreen_height)
        
        let initialFrame: CGRect = self.animationType == .present ? offScreenFrame : onScreenFrame
//        var finalFrame = self.animationType == .present ? onScreenFrame : offScreenFrame
        
        animationView.frame = initialFrame
//
//        var animateDuration: CGFloat = 0.8
//
//        if self.animationType == .present {
//            animateDuration = CGFloat(self.transitionDuration(using: transitionContext))
//        }
//
//        UIView.animate(withDuration: animateDuration, delay: 0.0, usingSpringWithDamping: 300.0, initialSpringVelocity: 1,0, options: UInt8(UIViewAnimationOptions.allowUserInteraction.rawValue)|UInt8(UIViewAnimationOptions.beginFromCurrentState.rawValue), animations: {
//            animationView.frame =  finalFrame
//        }) { (finished) in
//            if !(self.animationType == .present) {
//                fromView.removeFromSuperview()
//            }
//            transitionContext .completeTransition(true)
//        }
        
        toView?.frame = UIScreen.main.bounds
        toView?.alpha = 0
        
        let inputImage = self.screenSnapshot(save: false)
        let image = ImageProcessor.init(image: inputImage).blured()
        toView?.backgroundColor = UIColor.init(patternImage: image!)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            toView?.alpha = 1.0
        }) { (finish) in
            transitionContext .completeTransition(true)
        }
    }
    
    func screenSnapshot(save: Bool) -> UIImage? {
        guard let window = UIApplication.shared.keyWindow else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0)
        window.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if save {
            UIImageWriteToSavedPhotosAlbum(image!, self, nil, nil)
        }
        return image
    }
 
//    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return self
//    }
//    
//    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return self
//    }
}
