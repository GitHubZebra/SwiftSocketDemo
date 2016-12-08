//
//  VoiceInputManager.swift
//  SwiftSocketDemo
//
//  Created by Zebra on 2016/11/18.
//  Copyright © 2016年 Zebra. All rights reserved.
//

import UIKit

typealias VoiceInputBlockPower = (MessageM) -> ()

class VoiceInputManager: NSObject, AVAudioRecorderDelegate {
    
    var recorder: AVAudioRecorder? = nil
    
    var audioSession: AVAudioSession? = nil
    
    var recordPath: URL? = nil
    
    var timer: Timer? = nil
    
    var timer1: Timer? = nil
    
    var recordTime: Float = 0
    
    var block: VoiceInputBlockPower? = nil
    
    
    var recorderView: UIImageView? = nil
    
    var hub: UIView? = nil
    
    var signalView: UIImageView? = nil
    
    var tipLabel: UILabel? = nil
    
    var cancelView: UIImageView? = nil
    
    var signalImageArray: Array<UIImage>? = nil
    
    var otherId: String?
    
    
    func voiceInputEventsOfBtn(_ voiceInputBtn: UIButton, _ other_id: String, _ callBackPower: @escaping VoiceInputBlockPower) {
        
        self.block = callBackPower
        
        otherId = other_id;
        
        //单点触摸按下事件：点击下去，也就是长按，开始录音
        voiceInputBtn.rac_signal(for: .touchDown).subscribeNext { (any) in
            
            voiceInputBtn.setTitle("松开 结束", for: .normal)
            
            voiceInputBtn.backgroundColor = UIColor.j_color(withHex: 0xdddddd)
            
            self.createRecord()
            
            self.recorderHUD()
            
            self.createSignalImages()
            
            self.hubDefaultState()
        }
        
        //所有在控件之内触摸抬起事件，抬起手指，保存录音
        voiceInputBtn.rac_signal(for: .touchUpInside).subscribeNext { (any) in
            
            voiceInputBtn.setTitle("按住 说话", for: .normal)
            
            voiceInputBtn.backgroundColor = UIColor.white
            
            self.recordStop()
            
            if self.recordTime < 1 {
                
                self.hubInfolState()
                
            } else {
                
                self.hubRemove()
                
                DispatchQueue.global().async {
                    
                    ConventToMp3Tool.conventToMp3(withPath: self.recordPath?.absoluteString, andRecorder: self.recorder!)
                    
                    self.sendVoice()
                    
                }
                
            }
            
        }
        
        //当一次触摸从控件窗口内部拖动到外部时：往上滑，提示取消录音
        voiceInputBtn.rac_signal(for: .touchDragExit).subscribeNext { (any) in
            
//            voiceInputBtn.setTitle("往上滑，提示取消录音", for: .normal)
            
            self.recordPause()
            
            self.hubCancelState()
            
        }
        
        //所有在控件之外触摸抬起事件:往上滑后，抬起手指触发操作，取消录音
        voiceInputBtn.rac_signal(for: .touchUpOutside).subscribeNext { (any) in
            
//            voiceInputBtn.setTitle("取消录音", for: .normal)
            
            voiceInputBtn.backgroundColor = UIColor.white
            
            self.recordStop()
            
            self.hubRemove()
            
        }
        
        //当一次触摸从控件窗口之外拖动到内部时：往上滑后又往下滑回来，继续录音
        voiceInputBtn.rac_signal(for: .touchDragEnter).subscribeNext { (any) in
            
//            voiceInputBtn.setTitle("继续录音", for: .normal)
            
            self.recordStart()
            
            self.hubDefaultState()
            
        }
        
    }
    
    func createRecord() {
        
        audioSession = AVAudioSession.sharedInstance()
        
        try? audioSession?.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try? audioSession?.setActive(true)
        
        let recordSettings = [AVEncoderBitRateKey:16,AVNumberOfChannelsKey:2,AVSampleRateKey:8000.0] as [String : Any]
        
        recordPath = getSavePath()
        
        if (recorder != nil) {
            
            recorder?.stop()
            
            recorder = nil
            
        }
        
        recorder = try? AVAudioRecorder.init(url: recordPath!, settings: recordSettings)
        
        recorder?.delegate = self
        
        recorder?.prepareToRecord()
        
        recorder?.isMeteringEnabled = true
        
        if !(audioSession?.isInputAvailable)! {
            
            return
            
        }
        
        recordTime = 0
        
        resetTimer()
        
        recordStart()
        
        // 创建并启动定时器
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(VoiceInputManager.updateMeters),
                                     userInfo: nil,
                                     repeats: true)
        
    }
    
    func updateMeters() {
        
        self.recordTime += 0.1;
        
        if (recorder != nil) {
            
            recorder?.updateMeters()
        }
        
        let peakPower = recorder?.averagePower(forChannel: 0)
        
        let ALPHA: Float = 0.05
        
        let peakPowerForChannel = pow(10, (ALPHA * peakPower!))
        
        let level = ceil(Double(peakPowerForChannel / 0.1))
        
        print(level)
        
        changeImgOfLevel(Int(level))
        
    }
    
    /**
     *  取得录音文件保存路径
     *
     *  @return 录音文件路径
     */
    func getSavePath() -> URL {
        
        let currentDateTime = Date()
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "ddMMyyyyHHmmss"
        
        let recordingName = formatter.string(from: currentDateTime)
        
        let fileManager = FileManager.default
        
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        let documentDirectory = urls[0] as URL
        
        let soundURL = documentDirectory.appendingPathComponent(recordingName)
        
        return soundURL
        
    }
    
    /**
     *  开始/继续录音
     */
    func recordStart() {
        
        if !(recorder?.isRecording)! {
            do {
                try audioSession?.setActive(true)
                
                recorder?.record()
                
            }catch let error as NSError{
                
                print(error)
                
            }
        }
        
    }
    
    /**
     *  暂停录音
     */
    func recordPause() {
        
        if (recorder?.isRecording)! {
            
            recorder!.pause()
            
            timer?.fireDate = Date.distantFuture
            
        }
        
    }
    
    /**
     *  结束录音
     */
    func recordStop() {
        
        recorder?.stop()
        
        timer?.fireDate = Date.distantFuture
        
    }
    
    func resetTimer() {
        
        if (timer != nil) {
            
            timer?.invalidate()
            
            timer = nil
            
        }
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        print("完成")
        
    }
    
    func recorderHUD() {
        
        var x: CGFloat = ( JScreenWidth - 140 ) / 2
        
        var y: CGFloat = ( JScreenHeight - 140 ) / 2
        
        var width: CGFloat = 140
        
        var height: CGFloat = 140
        
        if hub == nil {
            
            hub = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
            
            hub?.backgroundColor = UIColor.init(white: 0.25, alpha: 0.9)
            
            hub?.layer.cornerRadius = 5
            
            JKeyWindow?.addSubview(hub!)
            
        } else {
            
            hub?.isHidden = false
            
        }
        
        
        
        let totalWidth: CGFloat = 110.0;
        
        x = (width - totalWidth)/2;
        
        y = x;
        
        width = 62;
        
        height = 100;
        
        if recorderView == nil {
            
            recorderView = UIImageView(frame: CGRect(x: x, y: y, width: width, height: height))
            
            hub?.addSubview(recorderView!)
            
            recorderView?.image = UIImage(named: "RecordingBkg")
            
        }
        
        
        
        x = (recorderView?.j_left)! + (recorderView?.j_width)! + 10
        
        width = 38
        
        height = 100
        
        if (signalView == nil) {
            
            signalView = UIImageView(frame: CGRect(x: x, y: y, width: width, height: height))
            
            hub?.addSubview(signalView!)
            
        }
        
        
        x = 5
        
        y = 110
        
        width = 130
        
        height = 25
        
        if (tipLabel == nil) {
            
            tipLabel = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
            
            tipLabel?.font = UIFont.systemFont(ofSize: 14)
            
            tipLabel?.textAlignment = .center
            
            tipLabel?.textColor = UIColor.white
            
            tipLabel?.layer.cornerRadius = 5
            
            tipLabel?.layer.masksToBounds = true
            
            hub?.addSubview(tipLabel!)
            
        }
        
        x = CGFloat((140 - 100)/2);
        
        y = x - 10;
        
        width = 100;
        
        height = width;
        
        if (cancelView == nil) {
            cancelView = UIImageView(frame: CGRect(x: x, y: y, width: width, height: height))
            
            hub?.addSubview(cancelView!)
            
            cancelView?.image = UIImage(named: "RecordCancel")
            
        }
        
    }
    
    func createSignalImages() {
        
        signalImageArray = []
        
        for i in 1...8 {
            
            let img = UIImage(named: "RecordingSignal00\(i)")
            
            signalImageArray?.append(img!)
            
        }
        
    }
    
    func changeImgOfLevel(_ level: Int) {
        
        if level == 0 || level > 8 {
            
            return
            
        }
        
        let img = signalImageArray?[level]
        
        signalView?.image = img
        
    }
    
    func hubDefaultState() {
        
        self.recorderView?.isHidden = false
        
        self.signalView?.isHidden = false
        
        self.cancelView?.isHidden = true
        
        self.tipLabel?.backgroundColor = UIColor.clear
        
        self.tipLabel?.text = "手指上滑, 取消发送";
        
    }
    
    func hubCancelState() {
        
        self.recorderView?.isHidden = true
        
        self.signalView?.isHidden = true
        
        self.cancelView?.isHidden = false
        
        self.cancelView?.image = #imageLiteral(resourceName: "RecordCancel")
        
        self.tipLabel?.backgroundColor = UIColor.init(red: 159/255.0, green: 45/255.0, blue: 0, alpha: 1.0)
        
        self.tipLabel?.text = "松开手指, 取消发送";
        
    }
    
    func hubInfolState() {
        
        self.recorderView?.isHidden = true
        
        self.signalView?.isHidden = true
        
        self.cancelView?.isHidden = false
        
        self.cancelView?.image = #imageLiteral(resourceName: "RecordInfo")
        
        self.tipLabel?.backgroundColor = UIColor.clear
        
        self.tipLabel?.text = "说话时间太短";
        
        timer1 = Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(VoiceInputManager.hubRemove),
                             userInfo: nil,
                             repeats: true)
        
        
    }
    
    func hubRemove() {
        
        hub?.isHidden = true
        
        timer1?.invalidate()
        
    }
    
    func sendVoice() {
        
        var path = recordPath!.absoluteString as NSString
        
        path = (path.replacingOccurrences(of: "file://", with: "") + ".mp3") as NSString
        
        TcpManager.sharedInstance.sendMessageOfRecord(URL(fileURLWithPath: path as String), toId: otherId, time:String(lroundf(recordTime))) { (messageM) in
            
            messageM.from_type = "1"
            
            self.block?(messageM)

        }
        
    }
    
    
}
