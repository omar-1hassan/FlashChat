//
//  Sender.swift
//  FlashChat
//
//  Created by mac on 14/09/2023.
//

import UIKit
import MessageKit

struct Sender: SenderType{
    let photoURL: String
    //Those attributes is provided by the MessageKit pod
    var senderId: String
    var displayName: String
}
