<p align="center">
  <img src="https://github.com/horitaku46/Assets/blob/master/Serrata/banner.png" width="600">
</p>

[![Platform](http://img.shields.io/badge/platform-iOS-blue.svg?style=flat)](https://developer.apple.com/iphone/index.action)
![Swift](https://img.shields.io/badge/Swift-4.0-orange.svg)
[![Cocoapods](https://img.shields.io/badge/Cocoapods-compatible-brightgreen.svg)](https://img.shields.io/badge/Cocoapods-compatible-brightgreen.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-Compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](http://mit-license.org)

## Overview
You can use it simply by passing the necessary information!  
Serrata is a UI library that allows you to intuitively view images.

<p align="center">
<img src="https://github.com/horitaku46/Assets/blob/master/Serrata/demo_0.gif" width="300">
<img src="https://github.com/horitaku46/Assets/blob/master/Serrata/demo_1.gif" width="300">
<img src="https://github.com/horitaku46/Assets/blob/master/Serrata/demo_2.gif" width="700">
</p>

## Features
[Kingfisher](https://github.com/onevcat/Kingfisher) is a lightweight and pure Swift implemented library.  
It is used in the Serrata. I sincerely respect Kingfisher!

- Support iPhone, iPad and iPhone X! 🎉
- It is the almost same as Image Viewer of Twitter and LINE.😎

## Requirements

- Xcode 9.0+
- iOS 11+
- Swift 4.0+

## Installation
#### Caution ⚠️
[Kingfisher](https://github.com/onevcat/Kingfisher) is installed, too!

### CocoaPods
```ruby
pod 'Serrata'
```

### Carthage
```ruby
github "horitaku46/Serrata"
```

## Usage
**See [Example](https://github.com/horitaku46/Serrata/tree/master/Example), for more details.**

How to use in Example.

```swift
guard let selectedCell = collectionView.cellForItem(at: indexPath) as? ImageCell else {
    return
}

let slideLeafs: [SlideLeaf] = images.enumerated().map { SlideLeaf(image: $0.1,
                                                                  title: "Image Title \($0.0)",
                                                                  caption: "Index is \($0.0)") }

let slideImageViewController = SlideLeafViewController.make(leafs: slideLeafs,
                                                            startIndex: indexPath.row,
                                                            fromImageView: selectedCell.imageView)

slideImageViewController.delegate = self // Please watch the following SlideLeafViewControllerDelegate.
present(slideImageViewController, animated: true, completion: nil)
```

Details of `SlideLeafViewController.make()`.

```swift
/// This method generates SlideLeafViewController.
///
/// - Parameters:
///   - leafs: It is array to display it by a slide.
///   - startIndex: It is for initial indication based on array of leafs.
///   - fromImageView: ImageView of the origin of transition. In the case of nil, CrossDissolve.
/// - Returns: Instance of SlideLeafViewController.
open class func make(leafs: [SlideLeaf], startIndex: Int = 0, fromImageView: UIImageView? = nil) -> SlideLeafViewController {
    // code...
}
```

Details of `SlideLeaf`.

```swift
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
```

#### delegate
Detail of `SlideLeafViewControllerDelegate`.

```swift
extension ViewController: SlideLeafViewControllerDelegate {

    func tapImageDetailView(slideLeaf: SlideLeaf, pageIndex: Int) {
        // code...
    }

    func longPressImageView(slideLeafViewController: SlideLeafViewController, slideLeaf: SlideLeaf, pageIndex: Int) {
        // code...
    }

    func slideLeafViewControllerDismissed(slideLeaf: SlideLeaf, pageIndex: Int) {
        // code...
    }
}
```

## Author
### Takuma Horiuchi
- [Facebook](https://www.facebook.com/profile.php?id=100008388074028)
- [Twitter](https://twitter.com/horitaku_)
- [GitHub](https://github.com/horitaku46)

## Example images from
- [Unsplash](https://unsplash.com/)

## License
`Serrata` is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.
