//
//  ExplodeAnimation.swift
//  TransitionKit
//
//  Created by leo on 2021/11/11.
//

import Foundation
import UIKit

class ExplodeAnimation: BasicAnimation {
    
    override func animateTransition(context: UIViewControllerContextTransitioning, fromViewController: UIViewController, toViewController: UIViewController, fromView: UIView, toView: UIView) {
        
        // Add the toView to the container
        let containerView = context.containerView
        containerView.addSubview(toView)
        containerView.sendSubviewToBack(toView)
        
        // final frame
        toView.frame = context.finalFrame(for: toViewController)
        
        // Create snapshot for each of the exploding pieces
        let size = fromView.frame.size
        let xCount = 10
        let yCount = 18
        let pieceWidth = size.width / CGFloat(xCount)
        let pieceHeight = size.height / CGFloat(yCount)
        
        var subSnapshots: [UIView] = []
        
        for x in 0 ..< xCount {
            for y in 0 ..< yCount {
                let snapshotRegion = CGRect(x: CGFloat(x) * pieceWidth, y: CGFloat(y) * pieceHeight, width: pieceWidth, height: pieceHeight)
                if let subViewSnapshot = fromView.resizableSnapshotView(from: snapshotRegion, afterScreenUpdates: false, withCapInsets: .zero) {
                    subViewSnapshot.frame = snapshotRegion
                    containerView.addSubview(subViewSnapshot)
                    subSnapshots.append(subViewSnapshot)
                }
            }
        }
        
        fromView.removeFromSuperview()
        
        // Animate
        UIView.animate(withDuration: self.duration) {
            for v in subSnapshots {
                let offsetX = self.randomFloatBetween(-100.0, 100.0)
                let offsetY = self.randomFloatBetween(-100.0, 100.0)
                v.frame = v.frame.offsetBy(dx: offsetX, dy: offsetY)
                v.alpha = 0.0
                // transform
                let scaleTransition = CGAffineTransform(rotationAngle: self.randomFloatBetween(-10.0, 10.0))
                let rotateTransition = CGAffineTransform(scaleX: 0.01, y: 0.01)
                v.transform = scaleTransition.concatenating(rotateTransition)
            }
        } completion: { _ in
            // Complete
            for v in subSnapshots {
                v.removeFromSuperview()
            }
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
    private func randomFloatBetween(_ min: CGFloat, _ max: CGFloat) -> CGFloat {
        let diff = max - min
        return (CGFloat(arc4random() % (UInt32(RAND_MAX) + 1)) / CGFloat(RAND_MAX)) * diff + min
    }
}
