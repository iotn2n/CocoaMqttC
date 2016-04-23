//
//  EventBus.swift
//  CocoaMqttC
//
//  Created by iotn2n on 16/4/23.
//  Copyright © 2016年 iot. All rights reserved.
//

import UIKit

class ChatLeftMessageCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel! {
        didSet {
            contentLabel.numberOfLines = 0
        }
    }
    @IBOutlet weak var avatarImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = UITableViewCellSelectionStyle.None
    }

}