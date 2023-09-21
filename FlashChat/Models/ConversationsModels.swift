//
//  ConversationsModels.swift
//  FlashChat
//
//  Created by mac on 21/09/2023.
//

import Foundation

struct Conversation{
    let id: String
    let name: String
    let otherUserEmail: String
    let latesMessage: LatestMessage
}
struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
