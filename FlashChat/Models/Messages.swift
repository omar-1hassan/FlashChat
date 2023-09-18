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
//    public var sender: MessageKit.SenderType
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
//    public var kind: MessageKit.MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self{
            
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return"video"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return"contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}
