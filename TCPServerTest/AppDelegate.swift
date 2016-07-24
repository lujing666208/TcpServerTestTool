//
//  AppDelegate.swift
//  TCPServerTest
//
//  Created by lujing on 16/7/24.
//  Copyright © 2016年 河南青云信息技术有限公司. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate,GCDAsyncSocketDelegate {

    @IBOutlet weak var window: NSWindow!

    var socket:GCDAsyncSocket!//监听socket
    var clientSocket:GCDAsyncSocket!//与客户端通信的socket
    @IBOutlet weak var portTF: NSTextField!
    @IBOutlet weak var sendTF: NSTextField!
    
    @IBOutlet weak var sendBtn: NSButton!
    @IBOutlet weak var receivedMsgTF: NSTextField!
    
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        print("Welcome")
        
        socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        //默认不使能，有客户端连接时才使能
        sendTF.enabled = false
        sendBtn.enabled = false
    }

    @IBAction func connectClick(sender: NSButton) {
        if sender.title == "Connect"{//未连接
            let portUInt = UInt16(portTF.intValue)
            do{
                try socket.acceptOnPort(portUInt)
                
                print("开放端口成功")
            }catch{
                print(error)
            }
            
            portTF.enabled = false
            sender.title = "Disconnect"
            
        } else {//已连接
            socket.disconnect()//监听socket断开，不再监听
            clientSocket.disconnect()//客户端socket断开，断开与客户端的连接
            
            sender.title = "Connect"
            portTF.enabled = true
        }
    }
    @IBAction func sendClick(sender: NSButton) {
        let data = sendTF.stringValue.dataUsingEncoding(NSUTF8StringEncoding)
        clientSocket.writeData(data, withTimeout: -1, tag: 1)
        
        sendTF.stringValue = ""
    }
    @IBAction func clearClick(sender: NSButton) {
        receivedMsgTF.stringValue = ""
    }
    
    func showMsg(str:String){
        receivedMsgTF.stringValue += "\n\(str)"
    }
    //MARK: - GCDAsyncSocketDelegate
    //收到连接请求
    func socket(sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        print("accept new socket: \(newSocket.connectedHost),\(newSocket.connectedPort)")
        clientSocket = newSocket
        
        sendTF.enabled = true
        sendBtn.enabled = true
        
        //等待接收数据
        clientSocket.readDataWithTimeout(-1, tag: 1)
        
    }
    //收到消息
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        let str = String(data: data, encoding: NSUTF8StringEncoding)
        //print("msg:\(str),tag:\(tag)")
        showMsg(str!)
        
        //持续接收数据
        clientSocket.readDataWithTimeout(-1, tag: 1)
    }
    //发送消息
    func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        print("向客户端发送消息成功！")
    }
    
    //断开连接
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        print("断开连接")
        if err != nil{
            print(err)
        }
        sendTF.enabled = false
        sendBtn.enabled = false
    }
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

