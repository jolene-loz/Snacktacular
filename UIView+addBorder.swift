//
//  UIView+addBorder.swift
//  Snacktacular
//
//  Created by J. Lozano on 11/20/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addBorder(width: CGFloat, radius: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = radius
        
    }
    
    func noBorder() {
        self.layer.borderWidth = 0.0
    }
}
