//
//  Messages.swift
//  FlashChat
//
//  Created by mac on 14/09/2023.
//

import UIKit
import MessageKit

struct Message: MessageType{
    //These attributes is given by the MesageKit Pod
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
}

