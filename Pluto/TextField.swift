//
//  TextField.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 1/11/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit

@IBDesignable
class TextField : UITextField {
    
    // MARK: - PROPERTIES
    
    @IBInspectable var inset: CGFloat = 0 // The space between the edge and the text.
    
    /* The following functions set the inset. */
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.insetBy(dx: inset, dy: inset)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        return textRect(forBounds: bounds)
    }
    
    @IBInspectable var placeholderTextColor: UIColor? {
        get {
            
            return self.placeholderTextColor
        } set {
            
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue!])
        }
    }
}
