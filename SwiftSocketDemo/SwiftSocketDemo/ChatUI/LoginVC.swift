//
//  LoginVC.swift
//  SwiftSocketDemo
//
//  Created by Zebra on 2016/11/4.
//  Copyright © 2016年 Zebra. All rights reserved.
//

import UIKit

class LoginVC: UIViewController ,TcpManagerDelegate{
    
    let host = "123.57.205.188"
    
    let port: UInt16 = 2345
    
    @IBOutlet weak var idTF: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        TcpManager.sharedInstance.delegate = self

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        TcpManager.sharedInstance.delegate = nil
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    @IBAction func loginBtnClicked(_ sender: Any) {
        
        TcpManager.sharedInstance.login(ID: idTF.text!)
        
    }
    
    func loginSuccess(_ self_name: String, _ self_portrait: String) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatConfig") as UIViewController
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        var viewControllers = self.navigationController?.viewControllers
        
        viewControllers?.remove(at: 0)
        
        if let viewControllers = viewControllers {
            
            self.navigationController?.viewControllers = viewControllers

        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
