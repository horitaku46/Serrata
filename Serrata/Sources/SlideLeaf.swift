//
//  SlideLeaf.swift
//  Serrata
//
//  Created by Takuma Horiuchi on 2017/12/01.
//  Copyright © 2017年 Takuma Horiuchi. All rights reserved.
//

import UIKit

open class SlideLeaf: NSObject {

    open var image: UIImage?
    open var urlString: String?

    open var title: String
    open var caption: String

    public init(image: UIImage?, title: String = "", caption: String = "") {
        self.image = image
        self.title = title
        self.caption = caption
    }

    public init(urlString: String?, title: String = "", caption: String = "") {
        self.urlString = urlString;
        self.title = title
        self.caption = caption
    }
}
