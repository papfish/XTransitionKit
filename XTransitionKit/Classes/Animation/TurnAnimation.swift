//
//  TurnAnimation.swift
//  TransitionKit
//
//  Created by leo on 2021/11/11.
//

import Foundation
import UIKit

class TurnAnimation: BasicAnimation {
    
    override func animateTransition(context: UIViewControllerContextTransitioning, fromViewController: UIViewController, toViewController: UIViewController, fromView: UIView, toView: UIView) {
        
        // Add the toView to the container
        let containerView = context.containerView
        containerView.addSubview(toView)
        
        // Add a perspective transform
        var transform = CATransform3DIdentity
        transform.m34 = -0.001
        containerView.layer.sublayerTransform = transform
        
        // Give both viewControllers the same frame
        let initialFrame = context.initialFrame(for: fromViewController)
        fromView.frame = initialFrame
        toView.frame = initialFrame
        
        // Rotate the toView by 90 degress, hiding it
        toView.layer.transform = self.rotate(angle: self.reverse ? -Double.pi/2.0 : Double.pi/2.0)
        
        // Animate
        UIView.animateKeyframes(withDuration: self.duration, delay: 0.0, options: .calculationModeLinear) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                // Rotate the fromView
                fromView.layer.transform = self.rotate(angle: self.reverse ? Double.pi/2.0 : -Double.pi/2.0)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                // Rotate the toView
                toView.layer.transform = self.rotate(angle: 0)
            }
        } completion: { _ in
            // Complete
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
    
    // Make rotation to y axis whith angle
    private func rotate(angle: Double) -> CATransform3D {
        CATransform3DMakeRotation(angle, 0.0, 1.0, 0.0)
    }
}
