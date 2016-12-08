//
//  TcpManager.swift
//  SwiftSocketDemo
//
//  Created by Zebra on 2016/11/3.
//  Copyright © 2016年 Zebra. All rights reserved.
//

import UIKit

typealias FuncBlockModel = (MessageM) -> ()

@objc
protocol TcpManagerDelegate:NSObjectProtocol {
    
    ///连接成功 回调
    @objc optional func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16)
    
    ///断开 回调
    @objc optional func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?)
    
    ///收到消息 回调
    @objc optional func didReceiveMessages(_ messageM: MessageM)
    
    ///登录成功
    @objc optional func loginSuccess(_ self_name: String, _ self_portrait: String)
    
    ///信息发送成功 回调
    @objc optional func messageSendSuccess()
}



class TcpManager: NSObject, GCDAsyncSocketDelegate {
    
    /// tcp单例
    static let sharedInstance = TcpManager()
    
    /// tcp代理
    var delegate: TcpManagerDelegate?
    
    /// GCDAsyncSocket
    static let clientSocket = GCDAsyncSocket(delegate: sharedInstance, delegateQueue: DispatchQueue.global())
    
    ///发送消息
    public func sendMessageOfType(
        
        ///  1 群发（text type）  2 单聊（text type selfId selfPortrait selfName toId） 3 绑定self_id（selfId）
        _            send_type     : String? = "2",
        /// 消息类型（text/img）
        type         mes_type      : String? = "text",
        /// 消息内容（文字/图片）
        text         content       : String? = "",
        /// 自己的id
        selfId       self_id       : String? = "",
        /// 自己的头像
        selfPortrait self_portrait : String? = "",
        /// 自己的昵称
        selfName     self_name     : String? = "",
        /// 对方的id
        toId         to_id         : String? = "",
        
        callBack                   : FuncBlockModel?
        ) {
        
        let dic = [
            
            "send_type"     : send_type!,
            "mes_type"      : mes_type!,
            "content"       : content!,
            "self_id"       : self_id!,
            "self_portrait" : self_portrait!,
            "self_name"     : self_name!,
            "to_id"         : to_id!,

            ] as [String : Any]
        
        connect()

        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            TcpManager.clientSocket.write(jsonData, withTimeout: -1, tag: 1)
            
            switch send_type! {
                
                //单聊
                case "2":
                
                    let model = MessageM()
                    
                    model.mes_type = mes_type
                    
                    model.content = content
                    
                    model.from_type = "1"
                    
                    model.send_type = send_type
                    
                    model.self_name = self_name
                    
                    model.self_portrait = self_portrait
                    
                    model.other_id = to_id
                    
                    model.mes_time = "\(Date().timeIntervalSince1970)"
                    
                    //存到数据库
                    MessageDB.ShareManager.openDB()
                    
                    MessageDB.ShareManager.insertMessage(model)
                    
                    callBack?(model)
                
                //登录
                case "3":
                    
                    break
                    
                default:
                    
                    print("消息返回错误")
                
            }
            
        } catch {
            
            print("错误");
            
        }

    }
    
    public func sendMessageOfImg(_ messageImgs: Any, toId to_id: String?, callBack: FuncBlockModel?) {
        
        NetworkTool.post("http://test.heleyuezi.com/GW/Index/submit_chat_img", parameters: nil, uploadImage: messageImgs, size: CGSize(width: 0, height: 0), sizeKB: 60, andProgress: nil, andSucces: { (successValue) in
            
                let dataSource = successValue as! Dictionary<String, Any>
                
                self.sendMessageOfType("2", type: "img", text: dataSource["data"] as! String?, selfId: self_id, selfPortrait: self_portrait, selfName: self_name, toId: to_id, callBack: { (messageM) in
                    
                    messageM.contentImg = messageImgs as? UIImage
                    
                    callBack?(messageM)
                    
                })
            
        }, andFailure: { (failureValue) in
            
            
            
        }, andError: nil)
        
    }
    
    public func sendMessageOfRecord(_ mp3Url: URL, toId to_id: String?, time: String?, callBack: FuncBlockModel?) {
                
        NetworkTool.post("http://test.heleyuezi.com/GW/Index/submit_chat_img", parameters: nil, uploadingMp3Url: mp3Url, andProgress: nil, andSucces: { (successValue) in
            
            let dataSource = successValue as! Dictionary<String, Any>
            
            self.sendMessageOfType("2", type: "voice", text: (dataSource["data"] as! String?)! + "?" + time!, selfId: self_id, selfPortrait: self_portrait, selfName: self_name, toId: to_id, callBack: { (messageM) in

                messageM.contentRecord = mp3Url

                callBack?(messageM)

            })

        }, andFailure: { (failureValue) in
            
            
            
        }, andError: nil)
        
    }
    
    //MARK: - 发送文字消息
    public func sendMessageOfText(_ messageText: String?, toId to_id: String?, callBack: FuncBlockModel?) {
        
        sendMessageOfType("2", type: "text", text: messageText, selfId: self_id, selfPortrait: self_portrait, selfName: self_name, toId: to_id, callBack: { (messageM) in
            
                callBack?(messageM)

            })
        
    }
    
    //MARK: - 登录
    public func sendMessageOfLogin(ID id: String?) {
        
        sendMessageOfType("3",  selfId: id, callBack: nil)
        
    }
    
    //MARK:连接服务器成功
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        
        sendMessageOfLogin(ID: self_id)
        
        self.delegate?.socket?(sock, didConnectToHost: host, port: port)
        
        TcpManager.clientSocket.readData(withTimeout: -1, tag: 200)
        
    }
    
    //MARK:断开了
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
        againConnect()
        
        self.delegate?.socketDidDisconnect?(sock, withError: err)
        
    }
    
    //MARK:收到消息
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        
        var str = String(data: data, encoding: String.Encoding.utf8)
        
        guard (str != nil) else {
            
            return
            
        }
        
        str = "[" + str! + "]"
        
        str = (str?.replacingOccurrences(of: "}{", with: "},{"))
        
        let jsonData = str?.data(using: String.Encoding.utf8)
        
        print("\(str)")
        
        guard jsonData != nil else {
            
            print("数据为空")
            
            return
            
        }
        
        do {
            
            let data = try JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Array<Dictionary<String, Any>>
            
            if let dataSource = data {
                
                for dic in dataSource {
                    
                    DispatchQueue.main.async { [weak self] in
                    
                        switch (dic["mes_type"]) as! String {
                            
                        //收到消息回调
                        case "text", "img", "voice":
                            
                            if let model = MessageM.mj_object(withKeyValues: dic) {
                                
                                model.from_type = "2"
                                
                                model.self_name = self_name
                                
                                model.self_portrait = self_portrait
                                
                                MessageDB.ShareManager.insertMessage(model)
                                
                                MessageDB.ShareManager.updateUnreadOfOther_id(model.other_id!)
                                
                                self?.delegate?.didReceiveMessages?(model)
                                
                            }
                            
                        //登录成功回调
                        case "bind":
                            
                            UserDefaults.standard.set(dic["self_name"] as! String, forKey: "self_name")
                            
                            UserDefaults.standard.set(dic["self_portrait"] as! String, forKey: "self_portrait")
                            
                            UserDefaults.standard.synchronize()
                            
                            self?.delegate?.loginSuccess?((dic["self_name"]) as! String, (dic["self_portrait"]) as! String)
                            
                            TcpManager.clientSocket.readData(withTimeout: -1, tag: 200)
                            
                        default:
                            
                            print("消息返回错误")
                            
                        }
                        
                    }
                    
                }
                            
            }
            
            
        } catch {
            
            print("解析出错")
            
        }
        
        TcpManager.clientSocket.readData(withTimeout: -1, tag: 200)
        
    }
    
    //MARK:信息发送成功
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        
        print("------->   发送成功")
        
        self.delegate?.messageSendSuccess?()
        
    }
    
    //MAKE: - 断开连接
    func disConnect() {
        
        if TcpManager.clientSocket.isConnected {
            
            TcpManager.clientSocket.disconnect()
            
        }

    }
    
    //MAKE: - 重新连接
    func againConnect() {
        
        if TcpManager.clientSocket.isConnected {
            
            disConnect()
            
        }
        
        connect()

    }
    
    //MAKE: - 连接
    func connect() {
        
        if TcpManager.clientSocket.isDisconnected {

            do {
                
                try TcpManager.clientSocket.connect(toHost: host, onPort: port)
                
            } catch {
                
                print("error")
                
            }
            
        }
    
    }
    
    func login(ID id: String!) {
        
        
        UserDefaults.standard.set(id!, forKey: "self_id")
        
        UserDefaults.standard.synchronize()
        
        if TcpManager.clientSocket.isDisconnected {

            connect()
            
        } else {
            
            sendMessageOfLogin(ID: self_id)
            
        }
    }
    
    
}
