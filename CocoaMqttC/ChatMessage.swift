//
//  EventBus.swift
//  CocoaMqttC
//
//  Created by iotn2n on 16/4/23.
//  Copyright © 2016年 iot. All rights reserved.
//

import Foundation

class ChatMessage {
    
    let sender: String
    let content: String
    
    init(sender: String, content: String) {
        self.sender = sender
        self.content = content
    }
}