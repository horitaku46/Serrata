//
//  ImageCell.swift
//  Serrata
//
//  Created by Takuma Horiuchi on 2017/11/29.
//  Copyright © 2017年 Takuma Horiuchi. All rights reserved.
//

import UIKit

final class ImageCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.contentMode = .scaleAspectFill
        }
    }

    func configure(image: UIImage) {
        imageView.image = image
    }
}
