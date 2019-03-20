//
//  MessageCell.swift
//  TranslYAtor
//
//  Created by Leon Vladimirov on 2/2/19.
//  Copyright © 2019 Leon Vladimirov. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var myCellLabel: UILabel!
    @IBOutlet weak var MessageView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       commonInit()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    // sets the color of the message 
    func commonInit() {
        let Blue: UIColor =  UIColor(red: 9/255, green: 150/255, blue: 233/255, alpha: 1)
        MessageView.clipsToBounds = true
        MessageView.layer.cornerRadius = 15
    
        if reuseIdentifier! == "Request" {
            myCellLabel.textColor = UIColor.white
            MessageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
            MessageView.backgroundColor = Blue
        } else  {
            myCellLabel.textColor = UIColor.black
            MessageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner]
            MessageView.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0)
        }
        
    }
 
}
