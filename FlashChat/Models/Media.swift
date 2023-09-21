//
//  Media.swift
//  FlashChat
//
//  Created by mac on 21/09/2023.
//

import Foundation
import MessageKit

struct Media: MediaItem{
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
