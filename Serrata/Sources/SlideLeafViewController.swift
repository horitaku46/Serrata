//
//  SlideLeafViewController.swift
//  Serrata
//
//  Created by Takuma Horiuchi on 2017/11/29.
//  Copyright © 2017年 Takuma Horiuchi. All rights reserved.
//

import UIKit

private enum SlideLeafConst {
    static let minimumLineSpacing: CGFloat = 20
    static let cellBothEndSpacing: CGFloat = minimumLineSpacing / 2
    static let maxSwipeCancelVelovityY: CGFloat = 800
    static let imageTransitionDuration = 0.3
}

@objc public protocol SlideLeafViewControllerDelegate: class {
    @objc optional func tapImageDetailView(slideLeaf: SlideLeaf, pageIndex: Int)
    @objc optional func longPressImageView(slideLeafViewController: SlideLeafViewController, slideLeaf: SlideLeaf, pageIndex: Int)
    @objc optional func slideLeafViewControllerDismissed(slideLeaf: SlideLeaf, pageIndex: Int)
}

public final class SlideLeafViewController: UIViewController {

    public override var prefersStatusBarHidden: Bool {
        return true
    }

    public override func prefersHomeIndicatorAutoHidden() -> Bool {
        return isPrefersHomeIndicatorAutoHidden
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    public override var shouldAutorotate: Bool {
        return isShouldAutorotate
    }

    @IBOutlet weak private var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "SlideLeafCell", bundle: Bundle(for: SlideLeaf.self)), forCellWithReuseIdentifier: "SlideLeafCell")
            collectionView.isPagingEnabled = true
            collectionView.backgroundColor = .clear
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.contentInsetAdjustmentBehavior = .never
        }
    }

    @IBOutlet weak private var collectionViewLeadingConstraint: NSLayoutConstraint! { // default = 0
        didSet {
            collectionViewLeadingConstraint.constant = -SlideLeafConst.cellBothEndSpacing
        }
    }

    @IBOutlet weak private var collectionViewTrailingConstraint: NSLayoutConstraint! { // default = 0
        didSet {
            collectionViewTrailingConstraint.constant = SlideLeafConst.cellBothEndSpacing
        }
    }

    @IBOutlet weak private var flowLayout: UICollectionViewFlowLayout! {
        didSet {
            flowLayout.scrollDirection = .horizontal
            flowLayout.sectionInset = UIEdgeInsets(top: 0,
                                                   left: SlideLeafConst.cellBothEndSpacing,
                                                   bottom: 0,
                                                   right: SlideLeafConst.cellBothEndSpacing)
            flowLayout.minimumLineSpacing = SlideLeafConst.minimumLineSpacing
            flowLayout.minimumInteritemSpacing = 0
        }
    }

    @IBOutlet weak private var rotationBlackImageView: UIImageView! {
        didSet {
            rotationBlackImageView.contentMode = .scaleAspectFit
            rotationBlackImageView.backgroundColor = .black
        }
    }

    @IBOutlet private var panGesture: UIPanGestureRecognizer!

    @IBOutlet private var singleTapGesture: UITapGestureRecognizer!

    @IBOutlet weak private var imageDetailView: ImageDetailView! {
        didSet {
            imageDetailView.delegate = self
        }
    }

    weak public var delegate: SlideLeafViewControllerDelegate?

    private var isShouldAutorotate = true
    private var isPrefersHomeIndicatorAutoHidden = false

    private var serrataTransition = SerrataTransition()

    private var slideLeafs = [SlideLeaf]()
    private var pageIndex = 0

    lazy private var firstSetImageDetail: (() -> ())? = {
        setPageIndexOffSet()
        setImageDetailText(pageIndex)
        return nil
    }()

    private var originPanImageViewCenterY: CGFloat = 0
    private var panImageViewCenterY: CGFloat = 0
    private var selectedCell = SlideLeafCell()
    private var isDecideDissmiss = false

    /// This method generates SlideLeafViewController.
    ///
    /// - Parameters:
    ///   - leafs: It is array to display it by a slide.
    ///   - startIndex: It is for initial indication based on array of leafs.
    ///   - fromImageView: ImageView of the origin of transition. In the case of nil, CrossDissolve.
    /// - Returns: Instance of SlideLeafViewController.
    public class func make(leafs: [SlideLeaf], startIndex: Int = 0, fromImageView: UIImageView? = nil) -> SlideLeafViewController {
        let viewController = UIStoryboard(name: "SlideLeafViewController", bundle: Bundle(for: SlideLeafViewController.self))
            .instantiateViewController(withIdentifier: "SlideLeafViewController") as! SlideLeafViewController
        viewController.transitioningDelegate = viewController.serrataTransition
        viewController.slideLeafs = leafs
        viewController.pageIndex = (leafs.count - 1) >= startIndex ? startIndex : 0
        viewController.serrataTransition.setFromImageView(fromImageView)
        return viewController
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        if delegate == nil {
            // tapImageDetailView disabled
            imageDetailView.disabledDetailButton()
        }
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        firstSetImageDetail?()
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let indexPath = IndexPath(row: pageIndex, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? SlideLeafCell,
            let image = cell.imageView.image {

            rotationBlackImageView.image = image
            collectionView.isHidden = true

            coordinator.animate(alongsideTransition: { _ in
                self.setPageIndexOffSet()
            }) { _ in
                self.rotationBlackImageView.image = nil
                self.collectionView.isHidden = false
                self.collectionView.isScrollEnabled = true
                self.panGesture.isEnabled = true
            }
        }
    }

    @IBAction private func handleTapGesture(_ sender: Any) {
        getCurrentCell().scrollView.setZoomScale(1, animated: true)
        imageDetailView.isFadeOut ? imageDetailView.fadeIn() : imageDetailView.fadeOut()
        isPrefersHomeIndicatorAutoHidden = imageDetailView.isFadeOut ? true : false
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }

    @IBAction private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let view = sender.view else { return }

        switch sender.state {
        case .began:
            isShouldAutorotate = false
            imageDetailView.fadeOut()

            let cell = getCurrentCell()
            selectedCell = cell
            originPanImageViewCenterY = cell.imageView.center.y
            serrataTransition.interactor.hasStarted = true

            dismiss(animated: true) {
                if self.isDecideDissmiss {
                    let leaf = self.slideLeafs[self.pageIndex]
                    self.delegate?.slideLeafViewControllerDismissed?(slideLeaf: leaf, pageIndex: self.pageIndex)
                }
            }

        case .changed:
            let translation = sender.translation(in: view)
            panImageViewCenterY = selectedCell.imageView.center.y + translation.y
            selectedCell.imageView.center.y = panImageViewCenterY
            sender.setTranslation(.zero, in: view)

            let vertivalMovement = originPanImageViewCenterY - panImageViewCenterY
            /// 0.0 <-> 1.0
            let verticalPercent = fabs(vertivalMovement / view.frame.height)
            serrataTransition.interactor.update(verticalPercent)
            rotationBlackImageView.alpha = 1 - verticalPercent

        case .cancelled, .ended, .failed:
            isShouldAutorotate = true
            serrataTransition.interactor.hasStarted = false

            let velocityY = sender.velocity(in: view).y
            if fabs(velocityY) > SlideLeafConst.maxSwipeCancelVelovityY {
                view.isUserInteractionEnabled = false
                isDecideDissmiss = true

                UIView.animate(withDuration: SlideLeafConst.imageTransitionDuration, animations: {
                    self.rotationBlackImageView.alpha = 0
                    let isScrollUp = velocityY < 0
                    let height = self.view.frame.height
                    self.selectedCell.frame.origin.y = isScrollUp ? -height : height
                }, completion: { _ in
                    self.serrataTransition.interactor.finish()
                })

            } else {
                serrataTransition.interactor.cancel()
                imageDetailView.fadeIn()

                UIView.animate(withDuration: SlideLeafConst.imageTransitionDuration) {
                    self.rotationBlackImageView.alpha = 1
                    self.selectedCell.imageView.center.y = self.originPanImageViewCenterY
                }
            }

        default:
            break
        }
    }

    private func setPageIndexOffSet() {
        let screenWidth = UIScreen.main.bounds.width
        let newOffSetX = screenWidth * CGFloat(pageIndex)
        let totalSpaceX = SlideLeafConst.minimumLineSpacing * CGFloat(pageIndex)
        let newOffSet = CGPoint(x: newOffSetX + totalSpaceX, y: 0)
        collectionView.setContentOffset(newOffSet, animated: false)
    }

    private func setImageDetailText(_ pageIndex: Int) {
        if slideLeafs.isEmpty {
            dismiss(animated: true, completion: nil)
        } else {
            let title = slideLeafs[pageIndex].title
            let caption = slideLeafs[pageIndex].caption
            imageDetailView.setDetail(title, caption)
        }
    }

    private func getCurrentCell() -> SlideLeafCell {
        let indexPath = IndexPath(row: pageIndex, section: 0)
        guard let cell = collectionView.cellForItem(at: indexPath) as? SlideLeafCell else {
            return SlideLeafCell()
        }
        return cell
    }
}

extension SlideLeafViewController: UIScrollViewDelegate {

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isShouldAutorotate = false
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffSetX = scrollView.contentOffset.x
        let scrollViewWidth = scrollView.frame.width
        let newPageIndex = Int(round(contentOffSetX / scrollViewWidth))
        if pageIndex != newPageIndex {
            setImageDetailText(newPageIndex)
            pageIndex = newPageIndex
        }
        isShouldAutorotate = true
    }
}

extension SlideLeafViewController: SlideLeafCellDelegate {

    public func slideLeafScrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        imageDetailView.fadeOut()
    }

    public func slideLeafScrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale == 1 {
            imageDetailView.fadeIn()
        }
    }

    public func slideLeafScrollViewDidZoom(_ scrolView: UIScrollView) {
        let isEnabled = scrolView.zoomScale == 1
        collectionView.isScrollEnabled = isEnabled
        panGesture.isEnabled = isEnabled
    }

    public func longPressImageView() {
        let leaf = slideLeafs[pageIndex]
        delegate?.longPressImageView?(slideLeafViewController: self, slideLeaf: leaf, pageIndex: pageIndex)
    }
}

extension SlideLeafViewController: ImageDetailViewDelegate {

    public func tapCloseButton() {
        dismiss(animated: true) {
            let leaf = self.slideLeafs[self.pageIndex]
            self.delegate?.slideLeafViewControllerDismissed?(slideLeaf: leaf, pageIndex: self.pageIndex)
        }
    }

    public func tapDetailView() {
        dismiss(animated: true) {
            let leaf = self.slideLeafs[self.pageIndex]
            self.delegate?.tapImageDetailView?(slideLeaf: leaf, pageIndex: self.pageIndex)
        }
    }
}

extension SlideLeafViewController: UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let displayCell = cell as? SlideLeafCell else {
            return
        }

        displayCell.delegate = self
        displayCell.scrollView.setZoomScale(1, animated: false)

        // conflict singleTap and doubleTap avoidance
        singleTapGesture.require(toFail: displayCell.doubleTapGesture)
    }
}

extension SlideLeafViewController: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slideLeafs.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlideLeafCell", for: indexPath) as! SlideLeafCell
        cell.resetImageView()
        cell.configure(slideLeaf: slideLeafs[indexPath.row])
        return cell
    }
}

extension SlideLeafViewController: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIScreen.main.bounds.size
    }
}
