//
//  UIVViewController-SLpopup.swift
//  AnonyChat
//
//  Created by Nguyen Duc Hoang on 9/6/15.
//  Copyright © 2015 Home. All rights reserved.
//

import UIKit
import QuartzCore
import ObjectiveC

enum SLpopupViewAnimationType: Int {
    case BottomTop
    case TopBottom
    case BottomBottom
    case TopTop
    case LeftLeft
    case LeftRight
    case RightLeft
    case RightRight
    case Fade
}
let kSourceViewTag = 11111
let kpopupViewTag = 22222
let kOverlayViewTag = 22222

var kpopupViewController:UInt8 = 0
var kpopupBackgroundView:UInt8 = 1

let kpopupAnimationDuration = 0.35
let kSLViewDismissKey = "kSLViewDismissKey"
var myPopupView: UIView?

extension UIViewController {
    var popupBackgroundView:UIView? {
        get {
            return objc_getAssociatedObject(self, &kpopupBackgroundView) as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kpopupBackgroundView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var popupViewController:UIViewController? {
        get {
            return objc_getAssociatedObject(self, &kpopupViewController) as? UIViewController
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kpopupViewController, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
//    var dismissedCallback:UIViewController? {
//        get {
//            return objc_getAssociatedObject(self, kSLViewDismissKey) as? UIViewController
//        }
//        set(newValue) {
//            objc_setAssociatedObject(self, kSLViewDismissKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
    func keyboardShown(notification: NSNotification) {
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        
        let rawFrame = value.CGRectValue
        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
        
        print("keyboardFrame: \(keyboardFrame)")
        
        myPopupView!.alpha = 1.0
        var myFrame:CGRect = (myPopupView?.frame)!
        myFrame.origin.y = self.getTopView().frame.size.height - (keyboardFrame.size.height + myFrame.size.height)
        UIView.animateWithDuration(kpopupAnimationDuration, animations: { () -> Void in
            self.popupViewController?.viewWillAppear(false)
            self.popupBackgroundView?.alpha = 0.5
            myPopupView!.frame = myFrame
            }) { (finished) -> Void in
                self.popupViewController?.viewDidAppear(false)
        }
    }
    func presentpopupViewController(popupViewController: UIViewController, animationType:SLpopupViewAnimationType, completion:() -> Void) {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardShown:", name: UIKeyboardDidShowNotification, object: nil)
        let sourceView:UIView = self.getTopView()
        self.popupViewController = popupViewController
        let popupView:UIView = popupViewController.view
        sourceView.tag = kSourceViewTag
        popupView.autoresizingMask = [.FlexibleTopMargin,.FlexibleLeftMargin,.FlexibleRightMargin,.FlexibleBottomMargin]
        popupView.tag = kpopupViewTag
        if(sourceView.subviews.contains(popupView)) {
            return
        }
        popupView.layer.shadowPath = UIBezierPath(rect: popupView.bounds).CGPath
//        popupView.layer.masksToBounds = false
//        popupView.layer.shadowOffset = CGSizeMake(5, 5)
//        popupView.layer.shadowRadius = 5
//        popupView.layer.shadowOpacity = 0.5
        popupView.layer.shouldRasterize = true
        popupView.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        let overlayView:UIView = UIView(frame: sourceView.bounds)
        overlayView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        overlayView.tag = kOverlayViewTag
        overlayView.backgroundColor = UIColor.clearColor()
        
        self.popupBackgroundView = UIView(frame: sourceView.bounds)
        self.popupBackgroundView!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.popupBackgroundView!.backgroundColor = UIColor.blackColor()
        self.popupBackgroundView?.alpha = 0.0
        if let _ = self.popupBackgroundView {
            overlayView.addSubview(self.popupBackgroundView!)
        }
        //Background is button
        let dismissButton: UIButton = UIButton(type: .Custom)
        dismissButton.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        dismissButton.backgroundColor = UIColor.clearColor()
        dismissButton.frame = sourceView.bounds
        overlayView.addSubview(dismissButton)
        
        popupView.alpha = 0.0
        overlayView.addSubview(popupView)
        sourceView.addSubview(overlayView)
        
        dismissButton.addTarget(self, action: "btnDismissViewControllerWithAnimation:", forControlEvents: .TouchUpInside)
        switch animationType {
        case .BottomTop, .BottomBottom,.TopTop,.TopBottom, .LeftLeft, .LeftRight,.RightLeft, .RightRight:
            dismissButton.tag = animationType.rawValue
            print("slider1")
            self.slideView(popupView, sourceView: sourceView, overlayView: overlayView, animationType: animationType)
            
        default:
            dismissButton.tag = SLpopupViewAnimationType.Fade.rawValue
            self.fadeView(popupView, sourceView: sourceView, overlayView: overlayView)
        }
        
    }
    func slideView(popupView: UIView, sourceView:UIView, overlayView:UIView, animationType: SLpopupViewAnimationType) {
        myPopupView = popupView
        let sourceSize: CGSize = sourceView.bounds.size
        let popupSize: CGSize = popupView.bounds.size
        var popupStartRect:CGRect
        switch animationType {
        case .BottomTop, .BottomBottom:
            popupStartRect = CGRectMake((sourceSize.width - popupSize.width)/2, sourceSize.height, popupSize.width, popupSize.height)
        case .LeftLeft, .LeftRight:
            popupStartRect = CGRectMake(-sourceSize.width, (sourceSize.height - popupSize.height)/2, popupSize.width, popupSize.height)
        case .TopTop, .TopBottom:
            popupStartRect = CGRectMake((sourceSize.width - popupSize.width)/2, -sourceSize.height, popupSize.width, popupSize.height)
        default:
            popupStartRect = CGRectMake(sourceSize.width, (sourceSize.height - popupSize.height)/2, popupSize.width, popupSize.height)
        }
        let popupEndRect:CGRect = CGRectMake((sourceSize.width - popupSize.width)/2, (sourceSize.height - popupSize.height)/2, popupSize.width, popupSize.height)
        popupView.frame = popupStartRect
        popupView.alpha = 1.0
        UIView.animateWithDuration(kpopupAnimationDuration, animations: { () -> Void in
            self.popupViewController?.viewWillAppear(false)
            self.popupBackgroundView?.alpha = 0.5
            popupView.frame = popupEndRect
            }) { (finished) -> Void in
                self.popupViewController?.viewDidAppear(false)
        }
        
    }
    func slideViewOut(popupView: UIView, sourceView:UIView, overlayView:UIView, animationType: SLpopupViewAnimationType) {
        let sourceSize: CGSize = sourceView.bounds.size
        let popupSize: CGSize = popupView.bounds.size
        var popupEndRect:CGRect
        switch animationType {
        case .BottomTop, .TopTop:
            popupEndRect = CGRectMake((sourceSize.width - popupSize.width)/2, -popupSize.height, popupSize.width, popupSize.height)
        case .BottomBottom, .TopBottom:
            popupEndRect = CGRectMake((sourceSize.width - popupSize.width)/2, popupSize.height, popupSize.width, popupSize.height)
        case .LeftRight, .RightRight:
            popupEndRect = CGRectMake(sourceSize.width, popupView.frame.origin.y, popupSize.width, popupSize.height)
        default:
            popupEndRect = CGRectMake(-popupSize.width, popupView.frame.origin.y, popupSize.width, popupSize.height)
        }
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.popupBackgroundView?.backgroundColor = UIColor.clearColor()
            }) { (finished) -> Void in
                UIView.animateWithDuration(kpopupAnimationDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.popupViewController?.viewWillDisappear(false)
                    popupView.frame = popupEndRect
                    }) { (finished) -> Void in
                        popupView.removeFromSuperview()
                        overlayView.removeFromSuperview()
                        self.popupViewController?.viewDidDisappear(false)
                        self.popupViewController = nil
                }
        }
        
        
        
    }
    
    func fadeView(popupView: UIView, sourceView:UIView, overlayView:UIView) {
        let sourceSize: CGSize = sourceView.bounds.size
        let popupSize: CGSize = popupView.bounds.size
        popupView.frame = CGRectMake((sourceSize.width - popupSize.width)/2,
                                                (sourceSize.height - popupSize.height)/2,
                                                popupSize.width,
                                                popupSize.height)
        popupView.alpha = 0.0
        
        UIView.animateWithDuration(kpopupAnimationDuration, animations: { () -> Void in
            self.popupViewController!.viewWillAppear(false)
            self.popupBackgroundView!.alpha = 0.5
            popupView.alpha = 1.0
        }) { (finished) -> Void in
           self.popupViewController?.viewDidAppear(false)
        }
        
    }
    
    func fadeViewOut(popupView: UIView, sourceView:UIView, overlayView:UIView) {
        UIView.animateWithDuration(kpopupAnimationDuration, animations: { () -> Void in
            self.popupViewController?.viewDidDisappear(false)
            self.popupBackgroundView?.alpha = 0.0
            popupView.alpha = 0.0
        }) { (finished) -> Void in
            popupView.removeFromSuperview()
            overlayView.removeFromSuperview()
            self.popupViewController?.viewDidDisappear(false)
            self.popupViewController = nil
        }
        
    }
    func btnDismissViewControllerWithAnimation(btnDismiss : UIButton) {
        let animationType:SLpopupViewAnimationType = SLpopupViewAnimationType(rawValue: btnDismiss.tag)!
        switch animationType {
        case .BottomTop, .BottomBottom, .TopTop, .TopBottom, .LeftLeft, .LeftRight, .RightLeft, .RightRight:
            self.dismissPopupViewController(animationType)
        default:
            self.dismissPopupViewController(SLpopupViewAnimationType.Fade)
        }
    }
    func getTopView() -> UIView {
        var recentViewController:UIViewController = self
        if let _ = recentViewController.parentViewController {
           recentViewController = recentViewController.parentViewController!
        }
        return recentViewController.view
    }
    func dismissPopupViewController(animationType: SLpopupViewAnimationType) {
        let sourceView:UIView = self.getTopView()
        let popupView:UIView = sourceView.viewWithTag(kpopupViewTag)!
        let overlayView:UIView = sourceView.viewWithTag(kOverlayViewTag)!
        switch animationType {
        case .BottomTop, .BottomBottom, .TopTop, .TopBottom, .LeftLeft, .LeftRight, .RightLeft, .RightRight:
            self.slideViewOut(popupView, sourceView: sourceView, overlayView: overlayView, animationType: animationType)
        default:
            fadeViewOut(popupView, sourceView: sourceView, overlayView: overlayView)
            
            
        }
    }
}