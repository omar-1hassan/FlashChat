//
//  ProfileViewModel.swift
//  FlashChat
//
//  Created by mac on 20/09/2023.
//

import UIKit

struct ProfileViewModel{
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}

enum ProfileViewModelType {
    case info, logout
}
