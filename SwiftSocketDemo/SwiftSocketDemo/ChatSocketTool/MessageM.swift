//
//  MessageM.swift
//  SwiftSocketDemo
//
//  Created by Zebra on 2016/11/3.
//  Copyright © 2016年 Zebra. All rights reserved.
//

import UIKit

class MessageM: NSObject {

    var messageId: Int?
    
    //MARK: 消息内容（文字/图片/语言）
    var content: String?
    
    //MARK: 自己显示的图片 不需要缓存
    var contentImg: UIImage?
    
    //MARK: 自己语音 不需要缓存
    var contentRecord: URL?
    
    //MARK: to 某某 id
    var to_client_id: String?
    
    //MARK: 1 我发出去的消息  2 我接受到的消息
    var from_type: String?
    
    //MARK: 0 未读 1 已读
    var isUnread: Int?
    
    //MARK: 消息类型（text/img/voice/bind）
    var mes_type: String?
    
    //MARK: 1 所有人  2 单人 3 绑定id
    var send_type: String?
    
    //MARK: 对方头像
    var other_portrait: String? = ""
    
    //MARK: 对方昵称
    var other_name: String? = ""
    
    //MARK: 对方id
    var other_id: String? = ""
    
    //MARK: 自己头像
    var self_portrait: String?
    
    //MARK: 自己昵称
    var self_name: String?
    
    //MARK: 消息时间
    var mes_time: String? = ""
    
}
