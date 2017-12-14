//
//  SlideLeafViewController.swift
//  SerrataSample
//
//  Created by Takuma Horiuchi on 2017/11/29.
//  Copyright © 2017年 Takuma Horiuchi. All rights reserved.
//

import UIKit

private enum SlideLeafConst {
    static let cellSpace: CGFloat = 20
    static let cellBothEndSpace: CGFloat = cellSpace / 2
}

@objc public protocol SlideLeafViewControllerDelegate: class {
    func tapImageDetailView(slideLeaf: SlideLeaf, pageIndex: Int)
    @objc func longPressImageView(slideLeafViewController: SlideLeafViewController, slideLeaf: SlideLeaf, pageIndex: Int)
}

 open class SlideLeafViewController: UIViewController {

    open override var prefersStatusBarHidden: Bool {
        return true
    }

    open override func prefersHomeIndicatorAutoHidden() -> Bool {
        return isPrefersHomeIndicatorAutoHidden
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    open override var shouldAutorotate: Bool {
        return isShouldAutorotate
    }

    @IBOutlet weak private var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "SlideLeafCell", bundle: nil), forCellWithReuseIdentifier: "SlideLeafCell")
            collectionView.isPagingEnabled = true
            collectionView.backgroundColor = .clear
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false
            collectionView.delegate = self
            collectionView.dataSource = self
            if #available(iOS 11.0, *) {
                collectionView.contentInsetAdjustmentBehavior = .never
            }
        }
    }

    @IBOutlet weak private var collectionViewLeadingConstraint: NSLayoutConstraint! { // default = 0
        didSet {
            collectionViewLeadingConstraint.constant = -SlideLeafConst.cellBothEndSpace
        }
    }

    @IBOutlet weak private var collectionViewTrailingConstraint: NSLayoutConstraint! { // default = 0
        didSet {
            collectionViewTrailingConstraint.constant = SlideLeafConst.cellBothEndSpace
        }
    }

    @IBOutlet weak private var flowLayout: UICollectionViewFlowLayout! {
        didSet {
            flowLayout.scrollDirection = .horizontal
            flowLayout.sectionInset = UIEdgeInsets(top: 0,
                                                   left: SlideLeafConst.cellBothEndSpace,
                                                   bottom: 0,
                                                   right: SlideLeafConst.cellBothEndSpace)
            flowLayout.minimumLineSpacing = SlideLeafConst.cellSpace
            flowLayout.minimumInteritemSpacing = 0
        }
    }

    @IBOutlet weak private var rotationBlackImageView: UIImageView! {
        didSet {
            rotationBlackImageView.contentMode = .scaleAspectFit
            rotationBlackImageView.backgroundColor = .black
        }
    }

    @IBOutlet private var singleTapGesture: UITapGestureRecognizer!

    @IBOutlet weak private var imageDetailView: ImageDetailView! {
        didSet {
            imageDetailView.delegate = self
        }
    }

    weak open var delegate: SlideLeafViewControllerDelegate?

    private var isShouldAutorotate = true
    private var isPrefersHomeIndicatorAutoHidden = false
    private var serrataTransition = SerrataTransition.shared

    private var slideLeafs = [SlideLeaf]()
    private var pageIndex = 0

    lazy private var setImageDetail: (() -> ())? = {
        setPageIndexOffSet()
        setImageDetailText(pageIndex)
        return nil
    }()

    private var originPanImageViewCenterX: CGFloat = 0
    private var panImageViewCenterX: CGFloat = 0
    private var selectedCell = SlideLeafCell()

    open class func make(leafs: [SlideLeaf], startIndex: Int = 0, fromImageView: UIImageView? = nil) -> SlideLeafViewController {
        let viewController = UIStoryboard(name: "SlideLeafViewController", bundle: nil)
            .instantiateViewController(withIdentifier: "SlideLeafViewController") as! SlideLeafViewController
        viewController.transitioningDelegate = viewController.serrataTransition
        viewController.slideLeafs = leafs
        viewController.pageIndex = startIndex
        viewController.serrataTransition.setFromImageView(fromImageView)
        return viewController
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        if delegate == nil {
            // tapImageDetailView disabled
            imageDetailView.disabledDetailButton()
        }
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setImageDetail?()
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
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
            }
        }
    }

    private func setPageIndexOffSet() {
        let screenWidth = UIScreen.main.bounds.width
        let newOffSetX = screenWidth * CGFloat(pageIndex)
        let totalSpaceX = SlideLeafConst.cellSpace * CGFloat(pageIndex)
        let newOffSet = CGPoint(x: newOffSetX + totalSpaceX, y: 0)
        collectionView.setContentOffset(newOffSet, animated: false)
    }

    @IBAction private func handleTapGesture(_ sender: Any) {
        imageDetailView.isFadeOut ? imageDetailView.fadeIn() : imageDetailView.fadeOut()
        if #available(iOS 11.0, *) {
            isPrefersHomeIndicatorAutoHidden = imageDetailView.isFadeOut ? true : false
            setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
    }

    @IBAction private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            isShouldAutorotate = false
            imageDetailView.fadeOut()

            let point = sender.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: point),
                let cell = collectionView.cellForItem(at: indexPath) as? SlideLeafCell {
                selectedCell = cell
                originPanImageViewCenterX = cell.imageView.center.y
                serrataTransition.interactor.hasStarted = true
                dismiss(animated: true, completion: nil)
            }

        case .changed:
            let translation = sender.translation(in: view)
            panImageViewCenterX = selectedCell.imageView.center.y + translation.y
            selectedCell.imageView.center.y = panImageViewCenterX
            sender.setTranslation(.zero, in: view)

            let vertivalMovement = originPanImageViewCenterX - panImageViewCenterX
            /// 0.0 <-> 1.0
            let verticalPercent = fabs(vertivalMovement / view.frame.height)
            serrataTransition.interactor.update(verticalPercent)
            rotationBlackImageView.alpha = 1 - verticalPercent

        case .cancelled, .ended, .failed:
            isShouldAutorotate = true
            serrataTransition.interactor.hasStarted = false

            let velocityY = fabs(sender.velocity(in: view).y)
            let isScrollUp = (originPanImageViewCenterX - panImageViewCenterX) > 0

            if velocityY > 800 {
                view.isUserInteractionEnabled = false

                UIView.animate(withDuration: 0.3, animations: {
                    self.rotationBlackImageView.alpha = 0
                    let height = self.view.frame.height
                    self.selectedCell.frame.origin.y = isScrollUp ? -height : height

                }, completion: { _ in
                    self.serrataTransition.interactor.finish()
                })

            } else {
                serrataTransition.interactor.cancel()
                imageDetailView.fadeIn()

                UIView.animate(withDuration: 0.3, animations: {
                    self.rotationBlackImageView.alpha = 1
                    self.selectedCell.imageView.center.y = self.originPanImageViewCenterX
                })
            }

        default:
            break
        }
    }

    private func setImageDetailText(_ pageIndex: Int) {
        let title = slideLeafs[pageIndex].title
        let caption = slideLeafs[pageIndex].caption
        imageDetailView.setDetail(title, caption)
    }
}

extension SlideLeafViewController: UIScrollViewDelegate {

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffSetX = scrollView.contentOffset.x
        let scrollViewWidth = scrollView.frame.width
        let newPageIndex = Int(round(contentOffSetX / scrollViewWidth))

        if pageIndex != newPageIndex {
            setImageDetailText(newPageIndex)
            pageIndex = newPageIndex
        }
    }
}

extension SlideLeafViewController: SlideLeafCellDelegate {

    open func slideLeafScrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        imageDetailView.fadeOut()
    }

    open func longPressImageView() {
        let leaf = slideLeafs[pageIndex]
        delegate?.longPressImageView(slideLeafViewController: self, slideLeaf: leaf, pageIndex: pageIndex)
    }
}

extension SlideLeafViewController: ImageDetailViewDelegate {

    open func tapCloseButton() {
        dismiss(animated: true, completion: nil)
    }

    open func tapDetailView() {
        dismiss(animated: true) {
            let leaf = self.slideLeafs[self.pageIndex]
            self.delegate?.tapImageDetailView(slideLeaf: leaf, pageIndex: self.pageIndex)
        }
    }
}

extension SlideLeafViewController: UICollectionViewDelegate {

    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
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

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slideLeafs.count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlideLeafCell", for: indexPath) as! SlideLeafCell
        cell.resetImageView()
        cell.configure(slideLeaf: slideLeafs[indexPath.row])
        return cell
    }
}

extension SlideLeafViewController: UICollectionViewDelegateFlowLayout {

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIScreen.main.bounds.size
    }
}
