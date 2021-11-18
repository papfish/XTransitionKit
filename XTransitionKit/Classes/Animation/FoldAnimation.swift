//
//  FoldAnimation.swift
//  TransitionKit
//
//  Created by leo on 2021/11/11.
//

import Foundation
import UIKit

class FoldAnimation: BasicAnimation {
    
    fileprivate let folds = 2
    
    override func animateTransition(context: UIViewControllerContextTransitioning, fromViewController: UIViewController, toViewController: UIViewController, fromView: UIView, toView: UIView) {
        
        // Add the toView to the container
        let containerView = context.containerView
        toView.frame = context.finalFrame(for: toViewController)
        toView.frame = toView.frame.offsetBy(dx: toView.frame.size.width, dy: 0)
        containerView.addSubview(toView)
        
        // Add a perspective transform
        var transform = CATransform3DIdentity
        transform.m34 = -0.005
        containerView.layer.sublayerTransform = transform
        
        let size = toView.frame.size
        
        let foldWidth = size.width * 0.5 / CGFloat(self.folds)
        
        // Arrays that hold the snapshot views
        var fromViewFolds: [UIView] = []
        var toViewFolds: [UIView] = []
        
        for i in 0 ..< self.folds {
            let offset = CGFloat(i) * foldWidth * 2.0
            
            // The left and right side of the fold for the fromView, with identity transform and 0.0 alpha
            // On the shadow, with each view at it's initial position
            guard let leftFromViewFold = self.createSnapshot(view: fromView, afterScreenUpdate: false, location: offset, left: true) else {
                return
            }
            leftFromViewFold.layer.position = CGPoint(x: offset, y: size.height/2)
            fromViewFolds.append(leftFromViewFold)
            leftFromViewFold.subviews[1].alpha = 0.0
            
            guard let rightFromViewFold = self.createSnapshot(view: fromView, afterScreenUpdate: false, location: offset + foldWidth, left: false) else {
                return
            }
            rightFromViewFold.layer.position = CGPoint(x: offset + foldWidth * 2, y: size.height/2)
            fromViewFolds.append(rightFromViewFold)
            rightFromViewFold.subviews[1].alpha = 0.0
            
            // The left and right side of the fold for the toView, with a 90-degree transform and 1.0 alpha
            // On the shadow, with each view positioned at the very edge of the screen
            guard let leftToViewFold = self.createSnapshot(view: toView, afterScreenUpdate: true, location: offset, left: true) else {
                return
            }
            leftToViewFold.layer.position = CGPoint(x: self.reverse ? size.width : 0.0, y: size.height/2)
            leftToViewFold.layer.transform = CATransform3DMakeRotation(Double.pi/2, 0.0, 1.0, 0.0)
            toViewFolds.append(leftToViewFold)
            
            guard let rightToViewFold = self.createSnapshot(view: toView, afterScreenUpdate: true, location: offset + foldWidth, left: false) else {
                return
            }
            rightToViewFold.layer.position = CGPoint(x: self.reverse ? size.width : 0.0, y: size.height/2)
            rightToViewFold.layer.transform = CATransform3DMakeRotation(-Double.pi/2, 0.0, 1.0, 0.0)
            toViewFolds.append(rightToViewFold)
        }
        
        // Move the from view off screen
        fromView.frame = fromView.frame.offsetBy(dx: fromView.frame.size.width, dy: 0)
        
        // Animate
        UIView.animate(withDuration: self.duration) {
            for i in 0 ..< self.folds {
                let offset = CGFloat(i) * foldWidth * 2.0
                
                // The left and right side of the fold for the fromView, with 90 degree transform and 1.0 alpha
                // On the shadow, with each view positioned at the edge of thw screen.
                let leftFromView = fromViewFolds[i * 2]
                leftFromView.layer.position = CGPoint(x: self.reverse ? 0.0 : size.width, y: size.height/2)
                leftFromView.layer.transform = CATransform3DRotate(transform, Double.pi/2, 0.0, 1.0, 0.0)
                leftFromView.subviews[1].alpha = 1.0
                
                let rightFromView = fromViewFolds[i * 2 + 1]
                rightFromView.layer.position = CGPoint(x: self.reverse ? 0.0 : size.width, y: size.height/2)
                rightFromView.layer.transform = CATransform3DRotate(transform, -Double.pi/2, 0.0, 1.0, 0.0)
                rightFromView.subviews[1].alpha = 1.0
                
                // the left and right side of the fold for the to- view, with identity transform and 0.0 alpha
                // on the shadow, with each view at its final position
                let leftToView = toViewFolds[i * 2]
                leftToView.layer.position = CGPoint(x: offset, y: size.height/2)
                leftToView.layer.transform = CATransform3DIdentity
                leftToView.subviews[1].alpha = 0.0
                
                let rightToView = toViewFolds[i * 2 + 1]
                rightToView.layer.position = CGPoint(x: offset + foldWidth * 2, y: size.height/2)
                rightToView.layer.transform = CATransform3DIdentity
                rightToView.subviews[1].alpha = 0.0
            }
        } completion: { _ in
            // Remove the snapshot views
            for v in toViewFolds {
                v.removeFromSuperview()
            }
            for v in fromViewFolds {
                v.removeFromSuperview()
            }
            
            // Complete
            let cancelled = context.transitionWasCancelled
            if cancelled {
                // Restore the fromView to the initial location if cancelled
                fromView.frame = containerView.bounds
            }else {
                // Restore the toView and fromView to the initial location
                toView.frame = containerView.bounds
                fromView.frame = containerView.bounds
            }
            context.completeTransition(!cancelled)
        }

    }
    
    private func createSnapshot(view: UIView, afterScreenUpdate: Bool, location: CGFloat, left: Bool) -> UIView? {
        
        guard let containerView = view.superview else {
            return nil
        }
        
        let size = view.frame.size
        let foldWidth = size.width * 0.5 / CGFloat(self.folds)
        
        var snapshotView: UIView?
        if !afterScreenUpdate {
            // Create a regular snapshot
            let snapshotRegion = CGRect(x: location, y: 0, width: foldWidth, height: size.height)
            snapshotView = view.resizableSnapshotView(from: snapshotRegion, afterScreenUpdates: afterScreenUpdate, withCapInsets: .zero)
        }else {
            // For the toView for some reason the snapshot takes a while to create. Here we place the snapshot within anthor view, whith the same background color, so that it is less noticeable when the snapshot initially renders
            snapshotView = UIView(frame: CGRect(x: 0, y: 0, width: foldWidth, height: size.height))
            snapshotView?.backgroundColor = view.backgroundColor
            let snapshotRegion = CGRect(x: location, y: 0, width: foldWidth, height: size.height)
            if let tempView = view.resizableSnapshotView(from: snapshotRegion, afterScreenUpdates: afterScreenUpdate, withCapInsets: .zero) {
                snapshotView!.addSubview(tempView)
            }
        }
        
        guard let snapshotView = snapshotView else {
            return nil
        }
        
        // Create a shadow
        let snapshotWithShadow = self.addShadow(view: snapshotView, reverse: left)
        
        // Add to the container
        containerView.addSubview(snapshotWithShadow)
        
        // Set the anchor to the left or right edge of the view
        snapshotWithShadow.layer.anchorPoint = CGPoint(x: left ? 0.0 : 1.0, y: 0.5)
        
        return snapshotWithShadow
    }
    
    private func addShadow(view: UIView, reverse: Bool) -> UIView {
        // Create a view with the same frame
        let viewWithShadow = UIView(frame: view.frame)
        
        // Create a shadow
        let shadowView = UIView(frame: viewWithShadow.bounds)
        let gradient = CAGradientLayer()
        gradient.frame = shadowView.bounds
        gradient.colors = [UIColor.init(white: 0.0, alpha: 0.0).cgColor, UIColor.init(white: 0.0, alpha: 1.0).cgColor]
        gradient.startPoint = CGPoint(x: reverse ? 0.0 : 1.0, y: reverse ? 0.2 : 0.0)
        gradient.endPoint = CGPoint(x: reverse ? 1.0 : 0.0, y: reverse ? 0.0 : 1.0)
        shadowView.layer.insertSublayer(gradient, at: 1)
        
        // Add the original view into our new view
        view.frame = view.bounds
        viewWithShadow.addSubview(view)
        
        // Place the shadow on top
        viewWithShadow.addSubview(shadowView)
        
        return viewWithShadow
    }
}
