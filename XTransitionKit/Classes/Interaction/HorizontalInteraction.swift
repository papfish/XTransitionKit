//
//  HorizontalInteraction.swift
//  TransitionKit
//
//  Created by leo on 2021/11/11.
//

import Foundation
import UIKit

class HorizontalInteraction: BasicInteraction {
    var holdViewController: UIViewController?
    var operation: InteractionOperation?
    var shouldComplete: Bool = false
    /**
     Indicates whether a navigation controller 'pop' should occur on a right-to-left, or a left-to-right
     swipe. This property does not affect tab controller or modal interactions.
     */
    var popOnRightToLeft: Bool = true
    
    var horizontalSwipeGestureKey: String = "horizontalSwipeGestureKey"
    
    override func wire(viewController: UIViewController, operation: InteractionOperation) {
        self.holdViewController = viewController
        self.operation = operation
        self.prepareGestureRecognizer(inView: viewController.view)
    }
    
    func prepareGestureRecognizer(inView: UIView) {
        
        if let gesture = objc_getAssociatedObject(inView, &horizontalSwipeGestureKey) {
            inView.removeGestureRecognizer(gesture as! UIGestureRecognizer)
        }
        
        // Add gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(recognizer:)))
        inView.addGestureRecognizer(panGesture)
        
        objc_setAssociatedObject(inView, &horizontalSwipeGestureKey, panGesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc func handleGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: recognizer.view?.superview)
        let velocity = recognizer.velocity(in: recognizer.view)
        
        switch recognizer.state {
        case .began:
            let swipeRightToLeft = velocity.x < 0
            
            // Mark the interacting flag. Used when supplying it in delegate.
            if self.operation == .pop {
                // For pop operation, fire on right-to-left
                if (self.popOnRightToLeft && swipeRightToLeft) || (!self.popOnRightToLeft && !swipeRightToLeft) {
                    self.interacting = true
                    self.holdViewController?.navigationController?.popViewController(animated: true)
                }
            }else if self.operation == .dismiss {
                self.interacting = true
                self.holdViewController?.dismiss(animated: true, completion: nil)
            }else if self.operation == .tab {
                // For tab controllers, we need to determine which direction to transition
                guard let tabbarController = self.holdViewController?.tabBarController else {
                    break
                }
                if swipeRightToLeft {
                    if let count = tabbarController.viewControllers?.count, tabbarController.selectedIndex < count - 1 {
                        self.interacting = true
                        tabbarController.selectedIndex = tabbarController.selectedIndex + 1
                    }
                }else {
                    if tabbarController.selectedIndex > 0 {
                        self.interacting = true
                        tabbarController.selectedIndex = tabbarController.selectedIndex - 1
                    }
                }
            }
            break
        case .changed:
            if self.interacting {
                // Calculate the percentage of guesture
                var fraction = abs(translation.x / 200.0)
                // Limit it between 0 and 1
                fraction = CGFloat(fminf(fmaxf(Float(fraction), 0.0), 1.0))
                
                self.shouldComplete = (fraction > 0.5)
                
                // if an interactive transitions is 100% completed via the user interaction, for some reason
                // the animation completion block is not called, and hence the transition is not completed.
                // This glorious hack makes sure that this doesn't happen.
                if fraction >= 1.0 {
                    fraction = 0.99
                }
                
                self.update(fraction)
            }
            break
        case .ended, .cancelled:
            // Gesture over. Check if the transition should happen or not
            if self.interacting {
                self.interacting = false
                if !self.shouldComplete || recognizer.state == .cancelled {
                    self.cancel()
                } else {
                    self.finish()
                }
            }
            break
        default:
            break
        }
    }
}
