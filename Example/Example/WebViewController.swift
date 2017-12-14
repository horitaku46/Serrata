//
//  WebViewController.swift
//  SerrataSample
//
//  Created by Takuma Horiuchi on 2017/12/13.
//  Copyright © 2017年 Takuma Horiuchi. All rights reserved.
//

import UIKit

final class WebViewController: UIViewController {

    class func make() -> UIViewController {
        let viewController = UIStoryboard(name: "WebViewController", bundle: nil)
            .instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        return viewController
    }
}
