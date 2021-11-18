//
//  VerticalInteraction.swift
//  TransitionKit
//
//  Created by leo on 2021/11/11.
//

import Foundation
import UIKit

class VerticalInteraction: BasicInteraction {
    var holdViewController: UIViewController?
    var operation: InteractionOperation?
    var shouldComplete: Bool = false
    
    var verticalSwipeGestureKey: String = "verticalSwipeGestureKey"
    
    override func wire(viewController: UIViewController, operation: InteractionOperation) {
        if operation == .tab {
            print("You cannot use a vertical swipe interaction with a tabbar controller - that would be silly!")
            return
        }
        
        self.holdViewController = viewController
        self.operation = operation
        self.prepareGestureRecognizer(inView: viewController.view)
    }
    
    func prepareGestureRecognizer(inView: UIView) {
        
        if let gesture = objc_getAssociatedObject(inView, &verticalSwipeGestureKey) {
            inView.removeGestureRecognizer(gesture as! UIGestureRecognizer)
        }
        
        // Add gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(recognizer:)))
        inView.addGestureRecognizer(panGesture)
        
        objc_setAssociatedObject(inView, &verticalSwipeGestureKey, panGesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc func handleGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: recognizer.view?.superview)
        
        switch recognizer.state {
        case .began:
            // Mark the interacting flag. Used when supplying it in delegate.
            if self.operation == .pop {
                self.interacting = true
                self.holdViewController?.navigationController?.popViewController(animated: true)
            }else if self.operation == .dismiss {
                self.interacting = true
                self.holdViewController?.dismiss(animated: true, completion: nil)
            }
            break
        case .changed:
            if self.interacting {
                // Calculate the percentage of guesture
                var fraction = abs(translation.y / 200.0)
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
