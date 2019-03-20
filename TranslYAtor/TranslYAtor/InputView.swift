//
//  InputView.swift
//  TranslYAtor
//
//  Created by Leon Vladimirov on 2/5/19.
//  Copyright © 2019 Leon Vladimirov. All rights reserved.
//

import UIKit

class InputView: UIView {
    let Blue: UIColor =  UIColor(red: 9/255, green: 150/255, blue: 233/255, alpha: 1)
    let Red: UIColor = UIColor(red: 237/255, green: 76/255, blue: 92/255, alpha: 1)
    
    override init(frame: CGRect){
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
   
    func switchColor() {
        if self.backgroundColor == Blue {
            self.backgroundColor = Red
        } else {
            self.backgroundColor = Blue
        }
        self.dropShadow(color: self.backgroundColor!, offSet: CGSize(width: -1, height: 1), radius: 7, scale: true)
    }
    func commonInit() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 20
        self.backgroundColor = Blue
        self.dropShadow(color: Blue, offSet: CGSize(width: -1, height: 1), radius: 7, scale: true)
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.3, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
