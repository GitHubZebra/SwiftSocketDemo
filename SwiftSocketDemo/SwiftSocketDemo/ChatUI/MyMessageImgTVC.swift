//
//  MyMessageImgTVC.swift
//  SwiftSocketDemo
//
//  Created by Zebra on 2016/11/16.
//  Copyright © 2016年 Zebra. All rights reserved.
//

import UIKit

class MyMessageImgTVC: UITableViewCell {

    @IBOutlet weak var portraitImg: UIImageView!
    
    @IBOutlet weak var recvBubbleBackgroundImage: UIImageView!
    
    @IBOutlet weak var titleL: UILabel!
    
    @IBOutlet weak var contentImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        var img = UIImage(named: "chat_sender_bg")
        
        img =  img?.stretchableImage(withLeftCapWidth: 20, topCapHeight: 30)
        
        recvBubbleBackgroundImage.image = img
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
