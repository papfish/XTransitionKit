//
//  CrossfadeAnimation.swift
//  TransitionKit
//
//  Created by leo on 2021/11/11.
//

import Foundation
import UIKit

class CrossfadeAnimation: BasicAnimation {
    
    override func animateTransition(context: UIViewControllerContextTransitioning, fromViewController: UIViewController, toViewController: UIViewController, fromView: UIView, toView: UIView) {
        
        // Add the toView to the container
        let containerView = context.containerView
        containerView.addSubview(toView)
        containerView.sendSubviewToBack(toView)
        
        // Set toView frame to final frame
        toView.frame = context.finalFrame(for: toViewController)
        
        // Animate
        UIView.animate(withDuration: self.duration) {
            fromView.alpha = 0.0
        } completion: { _ in
            // Complete
            fromView.alpha = 1.0
            if !context.transitionWasCancelled {
                fromView.removeFromSuperview()
            }
            context.completeTransition(!context.transitionWasCancelled)
        }

    }
}
