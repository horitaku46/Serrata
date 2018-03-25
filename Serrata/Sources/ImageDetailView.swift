//
//  ImageDetailView.swift
//  Serrata
//
//  Created by Takuma Horiuchi on 2017/12/08.
//  Copyright © 2017年 Takuma Horiuchi. All rights reserved.
//

import UIKit

private enum ImageDetailConst {
    static let maxAlpha: CGFloat = 0.4

    static let fadeInCloseButtonTop: CGFloat = 35
    static let fadeOutCloseButtonTop: CGFloat = 15

    static let fadeInDetailViewBottom: CGFloat = 0
    static let fadeOutDetailViewBottom: CGFloat = -20
}

public protocol ImageDetailViewDelegate: class {
    func tapCloseButton()
    func tapDetailView()
}

public final class ImageDetailView: UIView {

    public var isFadeOut = false

    public weak var delegate: ImageDetailViewDelegate?

    @IBOutlet weak private var closeButtonTopConstraint: NSLayoutConstraint! // default = 35
    @IBOutlet weak private var detailViewBottomConstraint: NSLayoutConstraint! // default = 0

    @IBOutlet weak private var closeButton: UIButton! { // UIButtonType = custom
        didSet {
            let closeImage = UIImage(named: "close_cross", in: Bundle(for: ImageDetailView.self), compatibleWith: nil)
            closeButton.setImage(closeImage, for: .normal)
            closeButton.setImage(closeImage, for: .highlighted)
            closeButton.layer.cornerRadius = closeButton.bounds.height / 2
            closeButton.backgroundColor = UIColor(white: 0, alpha: ImageDetailConst.maxAlpha)
        }
    }

    @IBOutlet weak private var detailView: UIView! {
        didSet {
            detailView.backgroundColor = UIColor(white: 0, alpha: ImageDetailConst.maxAlpha)
        }
    }

    @IBOutlet weak private var detailButton: UIButton! {
        didSet {
            detailButton.setBackgroundColor(color: .white, forState: .highlighted)
        }
    }

    @IBOutlet weak private var detailStackView: UIStackView! {
        didSet {
            detailStackView.isUserInteractionEnabled = false
            detailStackView.spacing = 2
        }
    }

    @IBOutlet weak private var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = .white
            titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
            titleLabel.textAlignment = .left
        }
    }

    @IBOutlet weak private var captionLabel: UILabel! {
        didSet {
            captionLabel.textColor = .white
            captionLabel.font = UIFont.systemFont(ofSize: 15)
            captionLabel.textAlignment = .left
            captionLabel.numberOfLines = 0
        }
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if self == hitView {
            return nil
        }
        return hitView
    }

    @IBAction private func tapCloseButton(_ sender: Any) {
        delegate?.tapCloseButton()
    }

    @IBAction private func tapDetailButton(_ sender: Any) {
        delegate?.tapDetailView()
    }

    public func disabledDetailButton() {
        detailButton.isEnabled = false
    }

    public func setDetail(_ title: String, _ caption: String) {
        if title != "" && caption != "" {
            titleLabel.text = title
            captionLabel.text = caption
        } else {
            detailView.isHidden = true
        }
    }

    public func fadeOut(with duration: TimeInterval = 0.2) {
        if !isFadeOut {
            isFadeOut = true
            closeButtonTopConstraint.constant = ImageDetailConst.fadeOutCloseButtonTop
            detailViewBottomConstraint.constant = ImageDetailConst.fadeOutDetailViewBottom

            UIView.animate(withDuration: duration) {
                self.closeButton.backgroundColor = UIColor(white: 0, alpha: 0)
                self.closeButton.alpha = 0

                self.detailView.backgroundColor = UIColor(white: 0, alpha: 0)
                self.detailView.alpha = 0

                self.layoutIfNeeded()
            }
        }
    }

    public func fadeIn(with duration: TimeInterval = 0.2) {
        if isFadeOut {
            isFadeOut = false
            closeButtonTopConstraint.constant = ImageDetailConst.fadeInCloseButtonTop
            detailViewBottomConstraint.constant = ImageDetailConst.fadeInDetailViewBottom

            UIView.animate(withDuration: duration) {
                self.closeButton.backgroundColor = UIColor(white: 0, alpha: ImageDetailConst.maxAlpha)
                self.closeButton.alpha = 1

                self.detailView.backgroundColor = UIColor(white: 0, alpha: ImageDetailConst.maxAlpha)
                self.detailView.alpha = 1

                self.layoutIfNeeded()
            }
        }
    }
}
