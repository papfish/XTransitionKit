//
//  CubeAnimation.swift
//  TransitionKit
//
//  Created by leo on 2021/11/11.
//

import Foundation
import UIKit

class CubeAnimation: BasicAnimation {
    
    override func animateTransition(context: UIViewControllerContextTransitioning, fromViewController: UIViewController, toViewController: UIViewController, fromView: UIView, toView: UIView) {
        
        // Add the toView to the container
        let containerView = context.containerView
        toView.frame = context.finalFrame(for: toViewController)
        containerView.addSubview(toView)
        containerView.sendSubviewToBack(toView)
        
        // Create transform for fromView and toView
        var fromViewTransform = CATransform3DMakeRotation(self.reverse ? Double.pi/2 : -Double.pi/2, 0.0, 1.0, 0.0)
        var toViewTransform = CATransform3DMakeRotation(self.reverse ? -Double.pi/2 : Double.pi/2, 0.0, 1.0, 0.0)
        fromViewTransform.m34 = -0.005
        toViewTransform.m34 = -0.005
        
        // Set anchor point to fromView and toView
        fromView.layer.anchorPoint = CGPoint(x: self.reverse ? 1.0 : 0.0, y: 0.5)
        toView.layer.anchorPoint = CGPoint(x: self.reverse ? 0.0 : 1.0, y: 0.5)
        
        // Rotate the toView by 90 degress, hiding it
        toView.layer.transform = toViewTransform
        
        let size = containerView.frame.size
        
        // Translation the containerView by half of container width
        containerView.transform = CGAffineTransform(translationX: self.reverse ? size.width/2 : -size.width/2, y: 0)
        
        // Create the shadow for fromView and toView, then return the shadow view
        let fromViewShadow = self.addShadow(view: fromView)
        let toViewShadow = self.addShadow(view: toView)
        fromViewShadow.alpha = 0.0
        toViewShadow.alpha = 1.0
        
        // Animate
        UIView.animate(withDuration: self.duration) {
            // Transform
            containerView.transform = CGAffineTransform(translationX: self.reverse ? -size.width/2 : size.width/2, y: 0.0)
            fromView.layer.transform = fromViewTransform
            toView.layer.transform = CATransform3DIdentity
            
            // Alpha
            fromViewShadow.alpha = 1.0
            toViewShadow.alpha = 0.0
            
        } completion: { _ in
            // Set the final position of every elements transformed
            containerView.transform = CGAffineTransform.identity
            fromView.layer.transform = CATransform3DIdentity
            toView.layer.transform = CATransform3DIdentity
            fromView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            toView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            // Remove the temporary view
            fromViewShadow.removeFromSuperview()
            toViewShadow.removeFromSuperview()
            
            let cancelled = context.transitionWasCancelled
            if cancelled {
                toView.removeFromSuperview()
            }else {
                fromView.removeFromSuperview()
            }
            
            // Complete
            context.completeTransition(!cancelled)
        }

    }
    
    // Create a shadow view whith alpha component
    private func addShadow(view: UIView) -> UIView {
        let shadowView = UIView(frame: view.bounds)
        shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.addSubview(shadowView)
        return shadowView
    }
}
