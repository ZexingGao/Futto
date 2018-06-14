//
//  GradientView.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/20/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable open class GradientView: UIView {
    @IBInspectable open var topColor: UIColor? {
        didSet {
            configureView()
        }
    }
    @IBInspectable open var bottomColor: UIColor? {
        didSet {
            configureView()
        }
    }

    override open class var layerClass : AnyClass {
        return CAGradientLayer.self
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    open override func tintColorDidChange() {
        super.tintColorDidChange()
        configureView()
    }

    static func makeGradient(_ view: UIView, topColor: UIColor? = nil, bottomColor: UIColor? = nil) {
        let layer = view.layer as! CAGradientLayer
        let locations = [ 0.0, 1.0 ]
        layer.locations = locations as [NSNumber]
        let color1 = topColor ?? AppColors.gradientTop
        let color2 = bottomColor ?? AppColors.gradientBottom
        let colors: Array <AnyObject> = [ color1.cgColor, color2.cgColor ]
        layer.colors = colors
    }

    func configureView() {
        GradientView.makeGradient(self, topColor: topColor, bottomColor: bottomColor);
    }
}
