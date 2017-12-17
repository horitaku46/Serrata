//
//  DetailViewController.swift
//  SerrataSample
//
//  Created by Takuma Horiuchi on 2017/12/13.
//  Copyright © 2017年 Takuma Horiuchi. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {

    private var detailTitle: String!

    class func make(detailTitle: String) -> UIViewController {
        let viewController = UIStoryboard(name: "DetailViewController", bundle: nil)
            .instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        viewController.detailTitle = detailTitle
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = detailTitle
    }
}
