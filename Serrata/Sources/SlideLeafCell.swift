//
//  SlideLeafCell.swift
//  Serrata
//
//  Created by Takuma Horiuchi on 2017/11/29.
//  Copyright © 2017年 Takuma Horiuchi. All rights reserved.
//

import UIKit
import Kingfisher

public protocol SlideLeafCellDelegate: class {
    func slideLeafScrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?)
    func slideLeafScrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat)
    func slideLeafScrollViewDidZoom(_ scrolView: UIScrollView)
    func longPressImageView()
}

public final class SlideLeafCell: UICollectionViewCell {

    @IBOutlet weak public var scrollView: UIScrollView! {
        didSet {
            scrollView.maximumZoomScale = 3
            scrollView.minimumZoomScale = 1
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.backgroundColor = .clear
            scrollView.delegate = self
        }
    }

    @IBOutlet weak private var activityIndicatorView: UIActivityIndicatorView! {
        didSet {
            activityIndicatorView.style = .whiteLarge
            activityIndicatorView.isHidden = true
        }
    }

    weak public var delegate: SlideLeafCellDelegate?

    public var doubleTapGesture: UITapGestureRecognizer!

    lazy public var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    public override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(_:)))
        imageView.addGestureRecognizer(longPressGesture)
    }

    public func configure(slideLeaf: SlideLeaf) {
        if let image = slideLeaf.image {
            setImage(image)

        } else if let url = slideLeaf.imageUrlString {
            activityIndicatorView.startAnimating()
            activityIndicatorView.isHidden = false

            imageView.kf.setImage(with: URL(string: url)) { [weak self] image, _, _, _ in
                guard let me = self, let image = image else { return }
                me.activityIndicatorView.isHidden = true
                me.activityIndicatorView.stopAnimating()
                me.setImage(image)
            }
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        if let image = imageView.image {
            scrollView.setZoomScale(1, animated: false)
            calcImageViewFrame(image)
        }
    }

    public func resetImageView() {
        imageView.image = nil
        scrollView.setZoomScale(1, animated: false)
    }

    private func setImage(_ image: UIImage) {
        imageView.image = image
        calcImageViewFrame(image)
        scrollView.addSubview(imageView)
    }

    private func calcImageViewFrame(_ image: UIImage) {
        let imageHeight = image.size.height
        let imageWidth = image.size.width
        let screenSize = UIScreen.main.bounds.size
        let hRate = screenSize.height / imageHeight
        let wRate = screenSize.width / imageWidth
        let rate = min(hRate, wRate)
        let imageViewSize = CGSize(width: floor(imageWidth * rate), height: floor(imageHeight * rate))
        imageView.frame.size = imageViewSize
        scrollView.contentSize = imageViewSize
        updateImageViewToCenter()
    }

    private func updateImageViewToCenter() {
        let screenSize = UIScreen.main.bounds.size
        let heightMargin = (screenSize.height - imageView.frame.height) / 2
        let widthMargin = (screenSize.width - imageView.frame.width) / 2
        scrollView.contentInset = UIEdgeInsets(top: max(heightMargin, 0),
                                               left: max(widthMargin, 0),
                                               bottom: 0,
                                               right: 0)
    }

    @objc private func handleDoubleTapGesture(_ sender: UITapGestureRecognizer) {
        if scrollView.maximumZoomScale > scrollView.zoomScale {
            let location = sender.location(in: imageView)
            let zoomRect = CGRect(origin: location, size: .zero)
            scrollView.zoom(to: zoomRect, animated: true)
            updateImageViewToCenter()
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }

    @objc private func longPressGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            delegate?.longPressImageView()
        }
    }
}

extension SlideLeafCell: UIScrollViewDelegate {

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegate?.slideLeafScrollViewDidZoom(scrollView)
        updateImageViewToCenter()
    }

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        delegate?.slideLeafScrollViewWillBeginZooming(scrollView, with: view)
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        delegate?.slideLeafScrollViewDidEndZooming(scrollView, with: view, atScale: scale)
    }
}
