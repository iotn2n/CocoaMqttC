//
//  LoginService.swift
//  CocoaMqttC
//
//  Created by iotn2n on 16/4/23.
//  Copyright © 2016年 iot. All rights reserved.
//

import Foundation
import SwiftEventBus
import Alamofire
import CocoaMQTT

class LoginService {
    
    var mqttc: CocoaMQTT?
    init() {
        
        mqttSetting(self)
        mqttc!.connect()
        
        SwiftEventBus.onBackgroundThread(self, name:"connect") { _ in
            if self.mqttc!.connState == CocoaMQTTConnState.CONNECTED {
                SwiftEventBus.postToMainThread("connect_ack")
            }
            else{
                self.mqttSetting(self)
                self.mqttc!.connect()
            }
            
        }
        
        SwiftEventBus.onBackgroundThread(self, name:"disConnect") { _ in
            print("disConnect get")
            self.mqttc!.disconnect()
        }
        
        SwiftEventBus.onBackgroundThread(self, name:"publish") { notification in
            let msg : CocoaMQTTMessage = notification.object as! CocoaMQTTMessage
            print("sendMessage get")
            self.mqttc!.publish(msg)
        }
        
    }
}

extension LoginService: CocoaMQTTDelegate {
    
    func mqttSetting(obj: CocoaMQTTDelegate?) {
        let uuid = GetUUID()
        let initUUID = uuid.uuid()
        let clientIdPid = "CocoaMQTT-\(initUUID!)-" + String(NSProcessInfo().processIdentifier)
        mqttc = CocoaMQTT(clientId: clientIdPid, host: "192.168.1.110", port: 1883)
        if let mqttc = mqttc {
            mqttc.username = "test"
            mqttc.password = "public"
            mqttc.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
            mqttc.keepAlive = 90
            mqttc.delegate = obj
        }
    }
    func mqtt(mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("didConnect \(host):\(port)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("didConnectAck \(ack.rawValue)")
        if ack == .ACCEPT {
            mqtt.subscribe("chat/room/animals/client/+", qos: CocoaMQTTQOS.QOS1)
            mqtt.ping()
            print("connect connect_ack")
            SwiftEventBus.postToMainThread("connect_ack")
        }
        
    }
    
    func mqtt(mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage with message: \(message.string)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck with id: \(id)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        print("didReceivedMessage: \(message.string) with id \(id)")
        SwiftEventBus.postToMainThread("receivedMessage", sender: message)
    }
    
    func mqtt(mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("didSubscribeTopic to \(topic)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic to \(topic)")
    }
    
    func mqttDidPing(mqtt: CocoaMQTT) {
        print("didPing")
    }
    
    func mqttDidReceivePong(mqtt: CocoaMQTT) {
        _console("didReceivePong")
    }
    
    func mqttDidDisconnect(mqtt: CocoaMQTT, withError err: NSError?) {
        _console("mqttDidDisconnect")
        SwiftEventBus.post("connect")
    }
    
    func _console(info: String) {
        print("Delegate: \(info)")
    }

}