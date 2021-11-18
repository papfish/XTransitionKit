//
//  TransitionKit.swift
//  TransitionKit
//
//  Created by leo on 2021/11/11.
//

import Foundation
import UIKit

/// Represents the available interaction items
public enum InteractionType: String {
    case none
    case horizontal
    case vertical
}

/// Represents the available animation items
public enum AnimationType: String {
    case none
    case flip
    case turn
    case fold
    case cube
    case explode
    case crossfade
}

/// Represents the available operation items for interaction
public enum InteractionOperation {
    case pop
    case dismiss
    case tab
}

/// Wrapper for TransitionKit compatible types. This type provides an extension point for
/// connivence methods in TransitionKit.
public struct TransitionKitWrapper<Base> {
    fileprivate let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

/// Represents a object type that is compatible with TransitionKit. You can use `tk` property to get a
/// value in the namespace of TransitionKit.
public protocol TransitionKitCompatible: AnyObject { }

extension TransitionKitCompatible {
    /// Gets a namespace holder for TransitionKit compatible types.
    public var tk: TransitionKitWrapper<Self> {
        get { return TransitionKitWrapper(self) }
        set { }
    }
    
//    public static var tk: TransitionKitWrapper<Self>.Type {
//        get { return TransitionKitWrapper<Self>.self }
//        set {  }
//    }
}

extension UIViewController: TransitionKitCompatible { }

@objc public protocol TransitionKitDelegate {
    // UIViewControllerTransitioningDelegate
    @objc optional func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    
    @objc optional func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?

    @objc optional func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?

    @objc optional func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?

    @objc optional func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?
    
    // UINavigationControllerDelegate
    @objc optional func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool)

    @objc optional func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool)

    @objc optional func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask

    @objc optional func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation

    @objc optional func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?

    @objc optional func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    
    // UITabBarControllerDelegate
    @objc optional func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool

    @objc optional func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)

    @objc optional func tabBarController(_ tabBarController: UITabBarController, willBeginCustomizing viewControllers: [UIViewController])

    @objc optional func tabBarController(_ tabBarController: UITabBarController, willEndCustomizing viewControllers: [UIViewController], changed: Bool)

    @objc optional func tabBarController(_ tabBarController: UITabBarController, didEndCustomizing viewControllers: [UIViewController], changed: Bool)

    @objc optional func tabBarControllerSupportedInterfaceOrientations(_ tabBarController: UITabBarController) -> UIInterfaceOrientationMask

    @objc optional func tabBarControllerPreferredInterfaceOrientationForPresentation(_ tabBarController: UITabBarController) -> UIInterfaceOrientation
    
    @objc optional func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?

    @objc optional func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
}

/// Keep the action and handle the delegate
fileprivate class TransitionDelegateObject: NSObject {
    fileprivate var delegate: TransitionKitDelegate?
    fileprivate var animation: Animation?
    fileprivate var interaction: Interaction?
}

extension TransitionDelegateObject: UIViewControllerTransitioningDelegate {
    
    /// View controller
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let animation = self.animation {
            if let interaction = self.interaction {
                interaction.wire(viewController: presented, operation: .dismiss)
            }
            animation.reverse = false
            return animation
        }
        return self.delegate?.animationController?(forPresented: presented, presenting: presenting, source: source)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let animation = self.animation {
            animation.reverse = true
            return animation
        }
        return self.delegate?.animationController?(forDismissed: dismissed)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let interaction = self.interaction, interaction.interacting {
            return interaction
        }
        return self.delegate?.interactionControllerForDismissal?(using: animator)
    }
    
    /// Independent function
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.delegate?.interactionControllerForPresentation?(using: animator)
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return self.delegate?.presentationController?(forPresented: presented, presenting: presenting, source: source)
    }
}

extension TransitionDelegateObject: UINavigationControllerDelegate {
    
    /// Navigation controller
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let interaction = self.interaction, interaction.interacting {
            return interaction
        }
        return self.delegate?.navigationController?(navigationController, interactionControllerFor: animationController)
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let animation = self.animation {
            animation.reverse = (operation == .pop)
            return animation
        }
        return self.delegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let interaction = self.interaction {
            interaction.wire(viewController: viewController, operation: .pop)
        }
        self.delegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }
    
    /// Independent function
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.delegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }

    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return self.delegate?.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? .portrait
    }
    
    func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return self.delegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? .portrait
    }
}

extension TransitionDelegateObject: UITabBarControllerDelegate {
    
    /// Tabbar controller
    func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let interaction = self.interaction, interaction.interacting {
            return interaction
        }
        return self.delegate?.tabBarController?(tabBarController, interactionControllerFor: animationController)
    }

    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let animation = self.animation {
            if let interaction = self.interaction {
                interaction.wire(viewController: toVC, operation: .tab)
            }
            if let fromIndex = tabBarController.viewControllers?.firstIndex(of: fromVC), let toIndex = tabBarController.viewControllers?.firstIndex(of: toVC) {
                animation.reverse = fromIndex < toIndex
            }
            return self.animation
        }
        return self.delegate?.tabBarController?(tabBarController, animationControllerForTransitionFrom: fromVC, to: toVC)
    }
    
    /// Independent function
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return self.delegate?.tabBarController?(tabBarController, shouldSelect: viewController) ?? true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.delegate?.tabBarController?(tabBarController, didSelect: viewController)
    }

    func tabBarController(_ tabBarController: UITabBarController, willBeginCustomizing viewControllers: [UIViewController]) {
        self.delegate?.tabBarController?(tabBarController, willBeginCustomizing: viewControllers)
    }

    func tabBarController(_ tabBarController: UITabBarController, willEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        self.delegate?.tabBarController?(tabBarController, willEndCustomizing: viewControllers, changed: changed)
    }

    func tabBarController(_ tabBarController: UITabBarController, didEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        self.delegate?.tabBarController?(tabBarController, didEndCustomizing: viewControllers, changed: changed)
    }

    func tabBarControllerSupportedInterfaceOrientations(_ tabBarController: UITabBarController) -> UIInterfaceOrientationMask {
        return self.delegate?.tabBarControllerSupportedInterfaceOrientations?(tabBarController) ?? .portrait
    }

    func tabBarControllerPreferredInterfaceOrientationForPresentation(_ tabBarController: UITabBarController) -> UIInterfaceOrientation {
        return self.delegate?.tabBarControllerPreferredInterfaceOrientationForPresentation?(tabBarController) ?? .portrait
    }
}

/// Keep the delegate for UIViewController
extension UIViewController {
    
    fileprivate struct AssociatedKey {
        static var ktInnerDelegateKey: String = "transitionKitInnerDelegate"
    }
    
    fileprivate weak var ktInnerDelegate: TransitionDelegateObject? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.ktInnerDelegateKey) as? TransitionDelegateObject
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.ktInnerDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

/// Setup delegate for UIViewController、UINavigationController、UITabBarController.
extension TransitionKitWrapper where Base: UIViewController {
    
    public var delegate: TransitionKitDelegate? {
        get { base.ktInnerDelegate?.delegate }
        set {
            let delegateObject = self.getDelegateObject()
            delegateObject.delegate = newValue
        }
    }
    
    public func setup(animationType: AnimationType?, interactionType: InteractionType?) {
        var animation: Animation?, interaction: Interaction?
        switch animationType {
        case .flip:
            animation = FlipAnimation()
            break
        case .turn:
            animation = TurnAnimation()
            break
        case .fold:
            animation = FoldAnimation()
            break
        case .cube:
            animation = CubeAnimation()
            break
        case .explode:
            animation = ExplodeAnimation()
            break
        case .crossfade:
            animation = CrossfadeAnimation()
            break
        default:
            break
        }
        
        switch interactionType {
        case .horizontal:
            interaction = HorizontalInteraction()
            break
        case .vertical:
            interaction = VerticalInteraction()
            break
        default:
            break
        }
        self.setup(animation: animation, interaction: interaction)
    }
    
    public func setup(animation: Animation?, interaction: Interaction?) {
        // Remove delegate
        if animation == nil && interaction == nil {
            base.ktInnerDelegate = nil
            return
        }
        // Add delegate
        let delegateObject = self.getDelegateObject()
        delegateObject.animation = animation
        delegateObject.interaction = interaction
        
        switch base {
        case let base as UINavigationController:
            base.delegate = delegateObject
            break
        case let base as UITabBarController:
            base.delegate = delegateObject
            // If set the interaction to UITabbarController, will wire to the selected viewController by default
            if let interaction = interaction, let selectedViewController = base.selectedViewController {
                interaction.wire(viewController: selectedViewController, operation: .tab)
            }
            break
        default:
            base.transitioningDelegate = delegateObject
            break
        }
    }
    
    public func remove() {
        self.setup(animation: nil, interaction: nil)
    }
    
    // Return the delegate object from base, Create it if not exist.
    private func getDelegateObject() -> TransitionDelegateObject {
        var delegateObject: TransitionDelegateObject
        if let hadDelegateObject = base.ktInnerDelegate {
            delegateObject = hadDelegateObject
        }else {
            delegateObject = TransitionDelegateObject()
            base.ktInnerDelegate = delegateObject
        }
        return delegateObject
    }
}

/// A protocol for interaction controllers that can be used with navigation controllers to perform pop operations, or with view controllers that have been presented modally to perform dismissal.
public protocol Interaction: UIPercentDrivenInteractiveTransition {
    /// This property indicates whether an interactive transition is in progress.
    var interacting: Bool { get set }
    
    func wire(viewController: UIViewController, operation: InteractionOperation)
}

/// Basic interaction
public class BasicInteraction: UIPercentDrivenInteractiveTransition, Interaction {
    public var interacting: Bool
    
    // Default
    override init() {
        self.interacting = false
    }
    
    public func wire(viewController: UIViewController, operation: InteractionOperation) {
        print("Please override: \(#function)")
    }
}

/**
 A protocol for animation controllers which provide reversible animations. A reversible animation is often used with navigation controllers where the reverse property is set based on whether this is a push or pop operation, or for modal view controllers where the reverse property is set based o whether this is a show / dismiss.
 */
public protocol Animation: UIViewControllerAnimatedTransitioning {
    /// The direction of the animation
    var reverse: Bool { get set }
    
    /// The animation duration.
    var duration: TimeInterval { get set }
    
    func animateTransition(context: UIViewControllerContextTransitioning, fromViewController: UIViewController, toViewController: UIViewController, fromView: UIView, toView: UIView)
}

/// Basic animation
public class BasicAnimation: NSObject, Animation {
    public var reverse: Bool
    
    public var duration: TimeInterval
    
    // Default
    override init() {
        self.reverse = false
        self.duration = 1.0
    }
    
    public func animateTransition(context: UIViewControllerContextTransitioning, fromViewController: UIViewController, toViewController: UIViewController, fromView: UIView, toView: UIView) {
        print("Please override: \(#function)")
        context.completeTransition(false)
    }
    
    // This is used for percent driven interactive transitions, as well as for
    // container controllers that have companion animations that might need to
    // synchronize with the main animation.
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }

    // This method can only be a no-op if the transition is interactive and not a percentDriven interactive transition.
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from), let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) {
            self.animateTransition(context: transitionContext, fromViewController: fromVC, toViewController: toVC, fromView: fromVC.view, toView: toVC.view)
        }
    }
}
