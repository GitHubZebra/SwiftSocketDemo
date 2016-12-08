//
//  MessageDB.swift
//  SwiftSocketDemo
//
//  Created by Zebra on 2016/11/14.
//  Copyright © 2016年 Zebra. All rights reserved.
//

import UIKit
import FMDB

class MessageDB: NSObject {

    ///单例
    static let ShareManager = MessageDB()
    
    ///创建一个dataBase的一个全局对象
    var dbQueue : FMDatabaseQueue?
    
    let messageTableName = "message_\(self_id!)"
    
    let unMessageCountTableName = "unread_message_count_\(self_id!)"
        
    func openDB() {
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        
        print(path)
        
        dbQueue = FMDatabaseQueue(path: "\(path)/messageDB")
        
        creatMessageTable()
        
        creatUnreadMessageTabel()
    }
    
    func runSQL(_ sql: String) -> Bool {
        
        var bool = false
        
        ///进行错误处理
        dbQueue?.inDatabase({ (db) -> Void in
            
            do {
                
                try db?.executeUpdate(sql, values: [])

                bool = true
                
            } catch {
                
                bool = false
                
            }
    
        })
        
        return bool
        
    }
    
    ///创建表的方法
    func creatMessageTable() {
        
        ///创建表  PRIMARY KEY('messageId')
        let sql = "CREATE TABLE IF NOT EXISTS \(messageTableName)(messageId integer NOT NULL, from_type text, mes_type text , content text , other_id text , other_portrait text , other_name text , self_portrait text , self_name text, mes_time text, PRIMARY KEY(messageId))"
    
        _ = runSQL(sql)
        
    }
    
    func creatUnreadMessageTabel() {
        
        let sql = "CREATE TABLE IF NOT EXISTS \(unMessageCountTableName)(other_id text, unread_count integer)"
        
       _ = runSQL(sql)
        
    }
    
    //MARK: - 插入消息
    func insertMessage(_ messageM: MessageM){
        
        self.openDB()
        
        let sql = "INSERT INTO \(messageTableName) (from_type, mes_type, content, other_id, other_portrait, other_name, self_portrait, self_name, mes_time) values ('\(messageM.from_type!)', '\(messageM.mes_type!)', '\(messageM.content!)', '\(messageM.other_id!)', '\(messageM.other_portrait!)', '\(messageM.other_name!)', '\(messageM.self_portrait!)', '\(messageM.self_name!)', '\(messageM.mes_time!)')"

        _ = runSQL(sql)
        
    }
    
    //MARK: - 插入未读消息个数
    func insertUnMessageCountOfOther_id(_ other_id: String?) {
        
        self.openDB()
        
        let sql = "INSERT INTO \(unMessageCountTableName)(other_id, unread_count) values('\(other_id!)', 1)"
        
        _ = runSQL(sql)
        
    }
    
    //MARK: - 删除未读消息个数
    func deleteUnMessageCountOfOther_id(_ other_id: String?) {
        
        self.openDB()
        
        let sql = "delete from \(unMessageCountTableName) where other_id = \(other_id!)"
        
        _ = runSQL(sql)
        
    }
    
    //MARK: - 删除消息
    func delete(){
        
        self.openDB()

        let sql = "delete from \(messageTableName)"
        
        _ = runSQL(sql)

    }
    
    //MARK: - 通过other_id修改未读消息个数
    func updateUnreadOfOther_id(_ other_id: String?){
        
        openDB()
        
        if queryUnMessageCountOfOther_id(other_id) != nil {
            
            let sql = "update \(unMessageCountTableName) set unread_count = unread_count + 1 where other_id = \(other_id!)"
            
            _ = runSQL(sql)

        } else {
            
            insertUnMessageCountOfOther_id(other_id)
            
        }
        
    }
    
    //MARK: - 查询所有消息
    func queryMessage(otherId other_id: String, page: Int) -> [MessageM]{
        
        var page = page
        self.openDB()
        
        if page <= 0 {
            page = 0
        }
        
        let sql = "select * from \(messageTableName) where other_id = \(other_id) order by messageId desc limit \(page * 50), 50"
        
        var resultArray: [MessageM] = []
        
        dbQueue?.inDatabase({ (db)->Void in
            
            ///执行查询
            if let result = try? db?.executeQuery(sql, values: []){
                
                ///遍历查询后的数据
                while (result?.next())!{
                    
                    let messageM = MessageM()

                    messageM.from_type = result?.string(forColumn: "from_type")
                    
                    messageM.mes_type = result?.string(forColumn: "mes_type")

                    messageM.content = result?.string(forColumn: "content")

                    messageM.other_id = result?.string(forColumn: "other_id")

                    messageM.other_portrait = result?.string(forColumn: "other_portrait")

                    messageM.other_name = result?.string(forColumn: "other_name")

                    messageM.self_portrait = result?.string(forColumn: "self_portrait")

                    messageM.self_name = result?.string(forColumn: "self_name")
                    
                    messageM.mes_time = result?.string(forColumn: "mes_time")
                    
                    resultArray.append(messageM)
                    
                }
            }
        })
        
        ///查找到数据后将数据返回
        return resultArray
    }

    //MARK: - 通过other_id 返回未读消息个数
    func queryUnMessageCountOfOther_id(_ other_id: String?) -> Int? {
        
        openDB()

        let sql = "select * from \(unMessageCountTableName) where other_id = \(other_id!)"
        
        var count:Int? = nil
        
        
        dbQueue?.inDatabase({ (db)->Void in
            
            ///执行查询
            if let result = try? db?.executeQuery(sql, values: []){
                
                if (result?.next())! {
                    
                    count = result?.long(forColumn: "unread_count")
                    
                }
                
            }
            
        })
        
        return count
        
    }
    
    //MARK: - 返回所有未读消息个数
    func queryUnMessageCountOfAll() -> Int? {
        
        openDB()
        
        let sql = "select * from \(unMessageCountTableName)"
        
        var count:Int? = nil
        
        
        dbQueue?.inDatabase({ (db)->Void in
            
            ///执行查询
            if let result = try? db?.executeQuery(sql, values: []){
                
                while (result?.next())!{
                    
                    count? += (result?.long(forColumn: "unread_count"))!
                    
                }
            }
            
        })
        
        return count
        
    }
    
    
}
