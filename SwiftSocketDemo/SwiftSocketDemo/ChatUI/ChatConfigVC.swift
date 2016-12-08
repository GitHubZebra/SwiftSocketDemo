//
//  ViewController.swift
//  SwiftSocketDemo
//
//  Created by Zebra on 2016/11/3.
//  Copyright © 2016年 Zebra. All rights reserved.
//

import UIKit

class ChatConfigVC: UIViewController {
    
    @IBOutlet weak var sendTypeTF: UITextField!

    @IBOutlet weak var IdTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "聊天配置"
        
        self.view.backgroundColor = UIColor.white
        
        self.j_tapDismissKeyboard()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let chatVC = segue.destination as! ChatVC
        
        chatVC.to_client_id = self.IdTF.text
        
        chatVC.send_type = Int(self.sendTypeTF.text!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

