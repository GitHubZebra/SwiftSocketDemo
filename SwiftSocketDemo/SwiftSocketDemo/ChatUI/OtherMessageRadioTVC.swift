//
//  OtherMessageRadioTVC.swift
//  SwiftSocketDemo
//
//  Created by Zebra on 2016/11/16.
//  Copyright © 2016年 Zebra. All rights reserved.
//

import UIKit

class OtherMessageRadioTVC: UITableViewCell {

    @IBOutlet weak var portraitImg: UIImageView!
    
    @IBOutlet weak var sendBubbleBackgroundImage: UIImageView!
    
    @IBOutlet weak var titleL: UILabel!
        
    @IBOutlet weak var radioImg: UIImageView!
    
    @IBOutlet weak var secondsL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        var img = UIImage(named: "chat_receiver_bg")
        
        img =  img?.stretchableImage(withLeftCapWidth: 15, topCapHeight: 35)
        
        sendBubbleBackgroundImage.image = img
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
