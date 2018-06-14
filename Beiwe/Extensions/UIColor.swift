//
//  UIColor.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/15/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//

import Foundation

extension UIColor {
    convenience init(_ r: Int, g: Int, b: Int, a: Double) {
        self.init(red: CGFloat(Double(r)/255.0), green: CGFloat(Double(g)/255.0), blue: CGFloat(Double(b)/255.0), alpha: CGFloat(a))
    }
}