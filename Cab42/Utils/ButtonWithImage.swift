//
//  ButtonWithImage.swift
//  Cab42
//
//  Created by Andres Margendie on 23/07/2018.
//  Copyright © 2018 Margendie Consulting LDT. All rights reserved.
//

import UIKit

class ButtonWithImage: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 5, left: (bounds.width - 35), bottom: 5, right: 5)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: (imageView?.frame.width)!)
        }
    }
}
