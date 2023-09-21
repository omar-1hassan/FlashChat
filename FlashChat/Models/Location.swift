//
//  Location.swift
//  FlashChat
//
//  Created by mac on 20/09/2023.
//

import Foundation
import MessageKit
import CoreLocation

struct Location: LocationItem {
    var location: CLLocation
    
    var size: CGSize
}
