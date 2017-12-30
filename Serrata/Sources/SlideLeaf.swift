//
//  SlideLeaf.swift
//  Serrata
//
//  Created by Takuma Horiuchi on 2017/12/01.
//  Copyright © 2017年 Takuma Horiuchi. All rights reserved.
//

import UIKit

public final class SlideLeaf: NSObject {

    public var image: UIImage?
    public var imageUrlString: String?

    public var title: String
    public var caption: String


    /// If either title and caption is empty, detailView is not displayed.
    ///
    /// - Parameters:
    ///   - image: To read by a slide.
    ///   - title: Title of the image.
    ///   - caption: Caption of the image.
    public init(image: UIImage?, title: String = "", caption: String = "") {
        self.image = image
        self.title = title
        self.caption = caption
    }

    /// If either title and caption is empty, detailView is not displayed.
    ///
    /// - Parameters:
    ///   - imageUrlString: To read by a slide. It is displayed by Kingfisher.
    ///   - title: Title of the image.
    ///   - caption: Caption of the image.
    public init(imageUrlString: String?, title: String = "", caption: String = "") {
        self.imageUrlString = imageUrlString
        self.title = title
        self.caption = caption
    }
}
