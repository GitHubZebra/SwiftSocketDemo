//
//  ChatVC.swift
//  SwiftSocketDemo
//
//  Created by Zebra on 2016/11/3.
//  Copyright © 2016年 Zebra. All rights reserved.
//

import UIKit
import MJRefresh

class ChatVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, TcpManagerDelegate {
    /**
     *  1 所有人  2 单人
     */
    var send_type: Int?
    
    var page: Int? = 0
    
    var recorder: AVAudioRecorder?
    
    /**
     *  to 某某 id
     */
    var to_client_id: String?
    
    var dataSource: Array<MessageM>! = []
    
    var avPlayer: AVPlayer?
    
    var animationImageView: UIImageView?
    
    
    @IBOutlet weak var chatBarChangeBtn: UIButton!
    
    @IBOutlet weak var radioBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sendTF: UITextView!
    
    @IBOutlet weak var sendTFBGViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var sendTFBgViewTop: NSLayoutConstraint!
    
    //MARK: 发送照片
    @IBAction func photoBtnClicked(_ sender: UIButton) {
        
        
        JCameraTool.j_creatAlert(self, andMinimumNumberOfSelection: 1, andMaximumNumberOfSelection: 1, andAllowsMultipleSelection: true, confirmBack: { (images) in
            
            TcpManager.sharedInstance.sendMessageOfImg(images!, toId:self.to_client_id ,callBack: { (messageM) in
                
                self.dataSourceAppend(messageM)
                
            })
            
        }, andCancelBack: nil)
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        if !dataSource.isEmpty {
            
            let indexPath = IndexPath(row: self.dataSource!.count - 1, section: 0)
            
            self.tableView!.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.bottom)
            
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let data = Array(MessageDB.ShareManager.queryMessage(otherId: self.to_client_id!, page: self.page!).reversed())
        
        if !data.isEmpty {
            
            dataSource! = data
            
        }
        
        self.createUI()
        
        MessageDB.ShareManager.deleteUnMessageCountOfOther_id(to_client_id!)
        
    }
    
    
    func createUI() {
        
        self.j_tapDismissKeyboard()
        
        self.view.backgroundColor = UIColor.j_color(withHex: 0xf1f1f1)
        
        self.tableView.backgroundColor = UIColor.j_color(withHex: 0xf1f1f1)
        
        self.tableView.keyboardDismissMode = .onDrag;
        
        TcpManager.sharedInstance.delegate = self
        
        self.sendTF.delegate = self
        
        self.sendTF.isScrollEnabled = false
        
        self.sendTF.rac_textSignal().subscribeNext { (text) in
            
            self.textViewChangeHeight()
            
        }
        
        self.addObserverKeyBoard()
        
        self.tableView!.mj_header = MJRefreshNormalHeader(refreshingBlock: { 
            
            self.page = self.page! + 1
            
            var arr = Array(MessageDB.ShareManager.queryMessage(otherId: self.to_client_id!, page: self.page!).reversed())
            
            for messageM in self.dataSource {
                
                arr.append(messageM)

            }
            
            self.dataSource! = arr
            
            self.tableView.reloadData()
            
            self.tableView.mj_header.endRefreshing()
            
        })
        
        self.chatBarChangeBtnClicked()
        
        self.chatBarRadioBtnClicked()
        
    }
    
    //MARK: - chatBarChangeBtn点击事件
    func chatBarChangeBtnClicked() {
        
        chatBarChangeBtn.rac_signal(for: .touchUpInside).subscribeNext { (any) in
            
            self.chatBarChangeBtn.isSelected = !self.chatBarChangeBtn.isSelected
            
            if self.chatBarChangeBtn.isSelected {
                
                self.sendTF.text = ""
                
                self.textViewChangeHeight()
                
                self.radioBtn.isHidden = false
                
                JKeyWindow?.endEditing(true)
                
            } else {
                
                self.radioBtn.isHidden = true
                
                self.sendTF.becomeFirstResponder()
                
            }
            
        }
        
        self.radioBtn.isHidden = true

    }
    
    
    //TODO: - 未完成  把语音录入 整体封装起来
    //MARK: - 语音输入
    func chatBarRadioBtnClicked() {
        
        VoiceInputManager().voiceInputEventsOfBtn(radioBtn, to_client_id!) { (messageM) in
            
            self.dataSourceAppend(messageM)
            
        }
        
    }

    //MARK: - 监听键盘
    func addObserverKeyBoard(){
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { (notification) in
            
            let value = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
            
            let keyBoardEndY: CGFloat = value.cgRectValue.size.height // 得到键盘弹出后的键盘视图所在y坐标
            
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
            
            UIView.animate(withDuration: duration, animations: {
                
                self.view.transform = CGAffineTransform(translationX: 0, y: -keyBoardEndY)
                
                var inset = self.tableView.contentInset
                
                inset.top = keyBoardEndY
                
                self.tableView.contentInset = inset
                
                if self.tableView.contentSize.height - self.tableView.bounds.size.height >= 0 {

                    let indexPath = IndexPath(row: self.dataSource!.count - 1, section: 0)
                    
                    self.tableView!.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.bottom)
                    
                }
            })
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { (notification) in
            
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
            
            UIView.animate(withDuration: duration, animations: {
                
                self.view.transform = .identity
                
                var inset = self.tableView.contentInset
                
                inset.top = 0
                
                self.tableView.contentInset = inset
                
            })
        }
    }
    
    //MARK: - 改变textView的高
    func textViewChangeHeight() {
        
//        guard self.sendTF.text.isEmpty == false else {
//            
//            self.sendTFBGViewHeight.constant = 50
//            
//            return
//            
//        }
        
        var bounds = self.sendTF.bounds
        
        let maxSize = CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude)
        
        let newSize = self.sendTF.sizeThatFits(maxSize)
        
        bounds.size = newSize
        
        bounds.size.width = JScreenWidth - 100
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.sendTF.bounds = bounds
            
            self.sendTFBGViewHeight.constant = self.sendTF.bounds.size.height + 20
            
            if !self.sendTF.text.isEmpty {
                
                self.view.layoutIfNeeded()
                
            }
            
            
        })
        
    }
    
    //MARK: - textViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            
            TcpManager.sharedInstance.sendMessageOfText(self.sendTF.text, toId: to_client_id, callBack: { (messageM) in
                
                self.sendTF.text = ""
                
                self.textViewChangeHeight()
                
                self.dataSourceAppend(messageM)
                
            })
            
            return false

        }
        
        return true
        
    }
    
    ///连接成功 回调
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        
        self.navigationItem.rightBarButtonItem!.title = "连接成功"

    }
    
    //MARK:断开 回调
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
        print("------->   断开了")
        
        self.navigationItem.rightBarButtonItem!.title = "断开了"
        
    }
    
    //MARK:收到消息 回调
    func didReceiveMessages(_ messageM: MessageM) {
        
        messageM.from_type = "2"
        
        MessageDB.ShareManager.deleteUnMessageCountOfOther_id(to_client_id!)
        
        self.dataSourceAppend(messageM)
                
    }
    
    //MARK: 信息发送成功 回调
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        
        print("------->   发送成功")
        
        self.navigationItem.rightBarButtonItem!.title = "发送成功"

        TcpManager.clientSocket.readData(withTimeout: -1, tag: 200)

    }

    func dataSourceAppend(_ model: MessageM) {
    
        self.dataSource!.append(model)
        
        self.tableView!.reloadData()
        
        self.tableView!.selectRow(at: IndexPath(row: self.dataSource!.count - 1, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.middle)
        
    }
    
    //MARK: tableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let messageM: MessageM = self.dataSource![indexPath.row]

        if messageM.mes_type == "text" {
            
            let content = NSString(string: messageM.content!)
            
            return content.j_height(with: UIFont.systemFont(ofSize: 14), constrainedTo: CGSize(width: JScreenWidth - 175, height: 10000)) + 63
            
        } else if messageM.mes_type == "img" {
            
            var photoHeight: Double =  0
            
            guard messageM.content != nil else {
                return 0
            }
            
            let array = messageM.content!.components(separatedBy: "?")
            
            let sizeArr = array[1].components(separatedBy: "*")
            
            let width = Double(sizeArr[0])
            
            let height = Double(sizeArr[1])
            
            if width! <= 200 {
                
                photoHeight = height! + 63.0
                
            }else{
                
                photoHeight = height!/(width! / 200) + 63;
                
            }

            return CGFloat(photoHeight)
            
        } else {
            
            return 80
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataSource!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messageM: MessageM = self.dataSource![indexPath.row]
        
        let from_type = Int(messageM.from_type!)
        
        let dateFormatter = DateFormatter();
        
        dateFormatter.dateFormat = "yyyy-MM-dd";
        
        switch messageM.mes_type! {
            
            case "text" where from_type == 1:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyTextIdentifier") as! MyMessageTextTVC
                
                cell.contentL!.text = messageM.content
                
                cell.portraitImg!.sd_setImage(with: URL(string: messageM.self_portrait!)!, placeholderImage: UIImage(named: "chat_default_portrait"))
                
                if let time = messageM.mes_time {
                    
                    let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(time)!))
                    
                    cell.titleL.text = dateString
                    
                }
                
                return cell
            
            case "text" where from_type == 2:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "OtherTextIdentifier") as! OtherMessageTextTVC
                
                cell.contentL!.text = messageM.content
                
                cell.portraitImg!.sd_setImage(with: URL(string: messageM.self_portrait!)!, placeholderImage: UIImage(named: "chat_default_portrait"))
                
                if let time = messageM.mes_time {
                    
                    let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(time)!))
                    
                    cell.titleL.text = dateString
                    
                }
                
                return cell
            
            case "voice" where from_type == 1:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyVoiceIdentifier") as! MyMessageRadioTVC
                
                cell.portraitImg!.sd_setImage(with: URL(string: messageM.self_portrait!)!, placeholderImage: UIImage(named: "chat_default_portrait"))
                
                if let time = messageM.mes_time {
                    
                    let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(time)!))
                    
                    cell.titleL.text = dateString
                    
                }
                
                let array = messageM.content!.components(separatedBy: "?")
                
                if array.count > 1 {
                    
                    cell.secondsL!.text = array[1] as String + "\""
                    
                }
                
                return cell
            
            case "voice" where from_type == 2:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "OtherVoiceIdentifier") as! OtherMessageRadioTVC
                
                cell.portraitImg!.sd_setImage(with: URL(string: messageM.self_portrait!)!, placeholderImage: UIImage(named: "chat_default_portrait"))
                
                if let time = messageM.mes_time , !time.isEmpty {
                    
                    let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(time)!))
                    
                    cell.titleL.text = messageM.other_name! + " " + dateString
                    
                } else {
                    
                    cell.titleL.text = messageM.other_name!
                    
                }
                
                let array = messageM.content!.components(separatedBy: "?")
                
                if array.count > 1 {
                    
                    cell.secondsL!.text = array[1] as String + "\""
                    
                }
                
                return cell
            
            case "img" where from_type == 1:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyImgIdentifier") as! MyMessageImgTVC
                
                cell.portraitImg!.sd_setImage(with: URL(string: messageM.self_portrait!)!, placeholderImage: UIImage(named: "chat_default_portrait"))
                
                if let time = messageM.mes_time , !time.isEmpty {
                    
                    let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(time)!))
                    
                    cell.titleL.text = messageM.other_name! + " " + dateString
                    
                } else {
                    
                    cell.titleL.text = messageM.other_name!
                    
                }
                
                
                if let img = messageM.contentImg {
                    
                    cell.contentImg.image = img
                    
                } else {
                    
                    cell.contentImg.sd_setImage(with: URL(string: messageM.content!), placeholderImage: nil)
                    
                }
                
                return cell
            
            case "img" where from_type == 2:

                let cell = tableView.dequeueReusableCell(withIdentifier: "OtherImgIdentifier") as! OtherMessageImgTVC
                
                cell.portraitImg!.sd_setImage(with: URL(string: messageM.self_portrait!)!, placeholderImage: UIImage(named: "chat_default_portrait"))
                
                if let time = messageM.mes_time , !time.isEmpty {
                    
                    let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(time)!))
                    
                    cell.titleL.text = messageM.other_name! + " " + dateString
                    
                } else {
                    
                    cell.titleL.text = messageM.other_name!
                    
                }
                
                if let img = messageM.contentImg {
                    
                    cell.contentImg.image = img
                    
                } else {
                    
                    cell.contentImg.sd_setImage(with: URL(string: messageM.content!), placeholderImage: nil)
                    
                }
                
                return cell
                
            default:
                
                return UITableViewCell()
                
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        avPlayerStop()
        
        let messageM: MessageM = self.dataSource![indexPath.row]
        
        let from_type = Int(messageM.from_type!)
        
        let dateFormatter = DateFormatter();
        
        dateFormatter.dateFormat = "yyyy-MM-dd";
        
        switch messageM.mes_type! {
            
        case "voice" where from_type == 1:
            
            let cell = tableView.cellForRow(at: indexPath) as! MyMessageRadioTVC
            
            animationImageView = cell.radioImg
            
            setUpVoicePlayIndicatorImageView(true)
            
            avPlayerStart(messageM.content!)

        case "voice" where from_type == 2:
            
            let cell = tableView.cellForRow(at: indexPath) as! OtherMessageRadioTVC
            
            animationImageView = cell.radioImg
            
            setUpVoicePlayIndicatorImageView(false)
            
            avPlayerStart(messageM.content!)
            
            
        default: break
        }
        
        
    }
    
    // 开始
    func avPlayerStart(_ strUrl: String) {
        // 判断AVPlayer是否为空
        if self.avPlayer != nil {
            
            avPlayerStop()
            
        }else{
            
            // 为空则重新实例化
            self.avPlayer = AVPlayer(url: URL(string: strUrl)!)
            
            self.avPlayer?.play()
            
            animationImageView?.startAnimating()
            
            NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.avPlayerStop), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            
        }
        
    }
    
    // 停止
    func avPlayerStop() {
        
        // AVPlayer没有stop的方法，所以只能先暂停，再清空
        self.avPlayer?.pause()
        
        self.avPlayer = nil
        
        animationImageView?.stopAnimating()

    }
    
    func setUpVoicePlayIndicatorImageView(_ send: Bool) {
        
        var images = NSArray()
        
        if send {
            
            images = NSArray(objects: UIImage(named: "chat_sender_audio_playing_000")!, UIImage(named: "chat_sender_audio_playing_001")!, UIImage(named: "chat_sender_audio_playing_002")!, UIImage(named: "chat_sender_audio_playing_003")!)
            
            animationImageView?.image = UIImage(named: "chat_sender_audio_playing_full")
            
        } else {
            
            images = NSArray(objects: UIImage(named: "chat_receiver_audio_playing000")!, UIImage(named: "chat_receiver_audio_playing001")!, UIImage(named: "chat_receiver_audio_playing002")!, UIImage(named: "chat_receiver_audio_playing003")!)
            
            animationImageView?.image = UIImage(named: "chat_receiver_audio_playing_full")
            
        }
        
        animationImageView?.animationImages = (images as! [UIImage])
        
        animationImageView?.animationDuration = 1
        
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
