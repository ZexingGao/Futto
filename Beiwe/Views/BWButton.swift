//
//  BWButton.swift
//  Beiwe
//
//  Created by Keary Griffin on 4/20/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//

import Foundation
import UIKit

class BWButton : UIButton {

    let fadeDelay = 0.0;
    override var isSelected: Bool {
        didSet {
            updateBorderColor();
        }
    }

    override var isHighlighted: Bool {
        didSet {
            updateBorderColor();
        }
    }

    override var isEnabled: Bool {
        didSet {
            updateBorderColor();
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.setTitleColor(UIColor.white, for: UIControlState.selected)
        self.setTitleColor(UIColor.white, for: UIControlState.highlighted)

        self.setTitleColor(UIColor.darkGray, for: UIControlState.disabled)
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        updateBorderColor();
    }

    func fadeHighlightOrSelectColor() {
        // Ignore if it's a race condition
        if (self.isEnabled && !(self.isHighlighted || self.isSelected)) {
            self.backgroundColor = UIColor.clear;
            self.layer.borderColor = UIColor.white.cgColor;
        }
    }

    func updateBorderColor() {
        if (self.isEnabled && (self.isHighlighted || self.isSelected)) {
            self.backgroundColor = AppColors.highlightColor
            self.layer.borderColor = AppColors.highlightColor.cgColor;
        } else if (self.isEnabled && !(self.isHighlighted || self.isSelected)) {
            if (self.fadeDelay > 0) {
                let delayTime = DispatchTime.now() + Double(Int64(self.fadeDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.fadeHighlightOrSelectColor();
                    }
            } else {
                self.fadeHighlightOrSelectColor();
            }
        } else {
            self.backgroundColor = UIColor.clear;
            self.layer.borderColor = UIColor.darkGray.cgColor;
        }
    }

}
