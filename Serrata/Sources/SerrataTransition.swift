//
//  SerrataTransition.swift
//  Serrata
//
//  Created by Takuma Horiuchi on 2017/11/29.
//  Copyright © 2017年 Takuma Horiuchi. All rights reserved.
//

import UIKit

public final class SerrataInteractor: UIPercentDrivenInteractiveTransition {
    public var hasStarted = false
}

public final class SerrataTransition: NSObject {

    private(set) var interactor = SerrataInteractor()
    private var fromImageView: UIImageView?
    private var isPresent = true

    public func setFromImageView(_ fromImageView: UIImageView?) {
        self.fromImageView = fromImageView
    }
}

extension SerrataTransition: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = true
        return self
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = false
        return self
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

extension SerrataTransition: UIViewControllerAnimatedTransitioning {

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresent {
            fromImageView != nil ? fromImageTransition(transitionContext) : crossDissolveTransition(transitionContext)
        } else {
            dissmissTransition(transitionContext)
        }
    }

    private func crossDissolveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
                return
        }
        let containerView = transitionContext.containerView

        toViewController.view.alpha = 0
        containerView.addSubview(toViewController.view)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toViewController.view.alpha = 1
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

    private func fromImageTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to) else {
                return
        }
        let containerView = transitionContext.containerView

        guard let fromImageView = fromImageView,
            let selectedImage = fromImageView.image else {
                return
        }

        fromImageView.isHidden = true

        let imageHeight = selectedImage.size.height
        let imageWidth = selectedImage.size.width
        var selectedImageViewFrame = containerView.convert(fromImageView.frame, from: fromImageView.superview)
        let rate = imageHeight > imageWidth ? (imageHeight / imageWidth) : (imageWidth / imageHeight)

        if imageHeight > imageWidth {
            let sizeHeight = selectedImageViewFrame.size.height * rate
            let originY = (sizeHeight - selectedImageViewFrame.size.height) / 2
            selectedImageViewFrame.origin.y -= originY
            selectedImageViewFrame.size.height = sizeHeight
        } else {
            let sizeWidth = selectedImageViewFrame.size.width * rate
            let originX = (sizeWidth - selectedImageViewFrame.size.width) / 2
            selectedImageViewFrame.origin.x -= originX
            selectedImageViewFrame.size.width = sizeWidth
        }

        let blackBlurView = UIView(frame: fromViewController.view.frame)
        blackBlurView.backgroundColor = .black
        blackBlurView.alpha = 0
        containerView.addSubview(blackBlurView)

        let wrapperSelectedImageView = UIImageView(image: selectedImage)
        wrapperSelectedImageView.frame = selectedImageViewFrame
        wrapperSelectedImageView.backgroundColor = .clear
        wrapperSelectedImageView.contentMode = .scaleAspectFit
        containerView.addSubview(wrapperSelectedImageView)

        toViewController.view.isHidden = true
        containerView.addSubview(toViewController.view)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            wrapperSelectedImageView.frame = toViewController.view.frame
            blackBlurView.alpha = 1
        }) { _ in
            fromImageView.isHidden = false
            blackBlurView.removeFromSuperview()
            wrapperSelectedImageView.removeFromSuperview()
            toViewController.view.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

    private func dissmissTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        let containerView = transitionContext.containerView

        toViewController.view.frame = transitionContext.finalFrame(for: fromViewController)
        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)

        /// landscape animation cancel avoidance
        let dummyClearView = UIView(frame: toViewController.view.frame)
        dummyClearView.backgroundColor = .clear
        containerView.insertSubview(dummyClearView, belowSubview: fromViewController.view)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            if self.interactor.hasStarted { // vertical swiped
                dummyClearView.alpha = 0
            } else { // closeButton tapped
                fromViewController.view.alpha = 0
            }
        }) { _ in
            dummyClearView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
