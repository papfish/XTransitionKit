//
//  FlipAnimation.swift
//  TransitionKit
//
//  Created by leo on 2021/11/11.
//

import Foundation
import UIKit

class FlipAnimation: BasicAnimation {
    
    override func animateTransition(context: UIViewControllerContextTransitioning, fromViewController: UIViewController, toViewController: UIViewController, fromView: UIView, toView: UIView) {
        
        // Add the toView to the container
        let containerView = context.containerView
        containerView.addSubview(toView)
        containerView.sendSubviewToBack(toView)
        
        // Add a perspective transform
        var transform = CATransform3DIdentity
        transform.m34 = -0.001
        containerView.layer.sublayerTransform = transform
        
        // Give both viewControllers the same start frame
        let initialFrame = context.initialFrame(for: fromViewController)
        fromView.frame = initialFrame
        toView.frame = initialFrame
        
        // Create two-part snapshots of both the fromViews and toViews
        guard let toViewSnapshots = self.createSnapshots(toView, afterScreenUpdates: true) else {
            return
        }
        
        guard let fromViewSnapshots = self.createSnapshots(fromView, afterScreenUpdates: true) else {
            return
        }
        
        var flippedSectionOfToView = toViewSnapshots[self.reverse ? 0 : 1]
        var flippedSectionOfFromView = fromViewSnapshots[self.reverse ? 1 : 0]
        
        // Replace the fromViews and toViews with container views that include gradients
        flippedSectionOfFromView = self.addShadow(flippedSectionOfFromView, reverse: !self.reverse)!
        let flippedSectionOfFromViewShadow = flippedSectionOfFromView.subviews[1]
        flippedSectionOfFromViewShadow.alpha = 0.0
        
        flippedSectionOfToView = self.addShadow(flippedSectionOfToView, reverse: self.reverse)!
        let flippedSectionOfToViewShadow = flippedSectionOfToView.subviews[1]
        flippedSectionOfToViewShadow.alpha = 1.0
        
        // Change the anchor point so that the view rotate around the correct edge
        self.updateAnchorPoint(CGPoint(x: self.reverse ? 0.0 : 1.0, y: 0.5), view: flippedSectionOfFromView)
        self.updateAnchorPoint(CGPoint(x: self.reverse ? 1.0 : 0.0, y: 0.5), view: flippedSectionOfToView)
        
        // Rotate the toView by 90 degress, hiding it
        flippedSectionOfToView.layer.transform = self.rotate(angle: self.reverse ? Double.pi/2 : -Double.pi/2)
        
        // Animate
        UIView.animateKeyframes(withDuration: self.duration, delay: 0, options: .calculationModeLinear) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                // Rotate the fromView to 90 degress
                flippedSectionOfFromView.layer.transform = self.rotate(angle: self.reverse ? -Double.pi/2 : Double.pi/2)
                flippedSectionOfFromViewShadow.alpha = 1.0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                // Rotate the toView to 0 degress
                flippedSectionOfToView.layer.transform = self.rotate(angle: self.reverse ? 0.001 : -0.001)
                flippedSectionOfToViewShadow.alpha = 0.0
            }
        } completion: { _ in
            // Remove all the temporary views
            if context.transitionWasCancelled {
                self.removeOtherViews(fromView)
            }else {
                self.removeOtherViews(toView)
            }
            
            // Inform the context of completion
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
    // Creates a pair of snapshots from the given view
    private func createSnapshots(_ view: UIView, afterScreenUpdates: Bool) -> Array<UIView>? {
        guard let containerView = view.superview else {
            return nil
        }
        
        // Snapshot the left-hand side of the view
        var snapshotRegion = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width/2.0, height: view.frame.size.height)
        guard let leftHandView = view.resizableSnapshotView(from: snapshotRegion, afterScreenUpdates: afterScreenUpdates, withCapInsets: .zero) else {
            return nil
        }
        
        leftHandView.frame = snapshotRegion
        containerView.addSubview(leftHandView)
        
        // Snapshot the right-hand side of the view
        snapshotRegion = CGRect(x: view.frame.origin.x + view.frame.size.width/2.0, y: view.frame.origin.y, width: view.frame.size.width/2.0, height: view.frame.size.height)
        guard let rightHandView = view.resizableSnapshotView(from: snapshotRegion, afterScreenUpdates: afterScreenUpdates, withCapInsets: .zero) else {
            return nil
        }
        
        rightHandView.frame = snapshotRegion
        containerView.addSubview(rightHandView)
        
        return [leftHandView, rightHandView]
    }
    
    // Adds a gradient to an image by creating a containing UIView with both the given view, and the gradient as subviews
    private func addShadow(_ view: UIView, reverse: Bool) -> UIView? {
        guard let containerView = view.superview else {
            return nil
        }
        
        // Create a view with the same frame
        let viewWithShadow = UIView(frame: view.frame)
        
        // Replace the view that we are adding a shadow to
        containerView.insertSubview(viewWithShadow, belowSubview: view)
        view.removeFromSuperview()
        
        // Create a shadow
        let shadowView = UIView(frame: viewWithShadow.bounds)
        let gradient = CAGradientLayer()
        gradient.frame = shadowView.bounds
        gradient.colors = [UIColor.init(white: 0.0, alpha: 0.0).cgColor, UIColor.init(white: 0.0, alpha: 0.5).cgColor]
        gradient.startPoint = CGPoint(x: reverse ? 0.0 : 1.0, y: 1.0)
        gradient.endPoint = CGPoint(x: reverse ? 1.0 : 0.0, y: 0.0)
        shadowView.layer.insertSublayer(gradient, at: 1)
        
        // Add the original view into our new view
        view.frame = view.bounds
        viewWithShadow.addSubview(view)
        
        // Place the shadow on top
        viewWithShadow.addSubview(shadowView)
        
        return viewWithShadow
    }
    
    // Updates the anchor point for the given view, offseting the frame to compensate for the resulting movement
    private func updateAnchorPoint(_ anchorPoint: CGPoint, view: UIView) {
        view.layer.anchorPoint = anchorPoint
        let offsetX = anchorPoint.x - 0.5
        view.frame = view.frame.offsetBy(dx: offsetX * view.frame.size.width, dy: 0)
    }
    
    // Make rotation to y axis whith angle
    private func rotate(angle: Double) -> CATransform3D {
        CATransform3DMakeRotation(angle, 0.0, 1.0, 0.0)
    }
    
    // Removes all the views other than the given view from the superview
    private func removeOtherViews(_ viewToKeep: UIView) {
        guard let containerView = viewToKeep.superview else {
            return
        }
        for view in containerView.subviews {
            if view != viewToKeep {
                view.removeFromSuperview()
            }
        }
    }
}
