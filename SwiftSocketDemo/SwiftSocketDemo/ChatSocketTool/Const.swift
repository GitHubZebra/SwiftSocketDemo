//
//  Const.swift
//  SwiftSocketDemo
//
//  Created by Zebra on 2016/11/14.
//  Copyright © 2016年 Zebra. All rights reserved.
//

import Foundation

let self_id = UserDefaults.standard.value(forKey: "self_id") as? String

let self_name = UserDefaults.standard.value(forKey: "self_name") as? String

let self_portrait = UserDefaults.standard.value(forKey: "self_portrait") as? String

let host = "123.57.205.188"

let port: UInt16 = 2345

// 当前系统版本
let Version = (UIDevice.current.systemVersion as NSString).doubleValue

///系统 8 ..< 9
let iOS_8_9  = Version >= 8.0 && Version < 9.0

///系统 8 ..< 10
let iOS_8_10 = Version >= 8.0 && Version < 10.0

///系统 10...
let iOS_10   = Version >= 10

let JScreenBounds = UIScreen.main.bounds

let JScreenSize = JScreenBounds.size

let JScreenHeight = JScreenSize.height

let JScreenWidth = JScreenSize.width

// NSUserDefault
let JUserDefault = UserDefaults.standard

// 通知中心
let JNotice = NotificationCenter.default

let JKeyWindow = UIApplication.shared.keyWindow

