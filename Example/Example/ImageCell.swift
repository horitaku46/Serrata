//
//  ImageCell.swift
//  SerrataSample
//
//  Created by Takuma Horiuchi on 2017/11/29.
//  Copyright © 2017年 Takuma Horiuchi. All rights reserved.
//

import UIKit
import Kingfisher

final class ImageCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.contentMode = .scaleAspectFill
        }
    }

    func configure(urlStr: String) {
        imageView.kf.setImage(with: URL(string: urlStr),
                              options: [.transition(.fade(0.2))])
    }
}
