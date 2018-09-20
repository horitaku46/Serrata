//
//  UIButtonExtension.swift
//  Serrata
//
//  Created by Takuma Horiuchi on 2017/12/08.
//  Copyright © 2017年 Takuma Horiuchi. All rights reserved.
//

import UIKit

extension UIButton {

    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        setBackgroundImage(colorImage, for: forState)
    }
}
