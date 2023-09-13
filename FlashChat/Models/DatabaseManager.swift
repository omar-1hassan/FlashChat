//
//  DatabaseManager.swift
//  FlashChat
//
//  Created by mac on 13/09/2023.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
}
//MARK: - Account managment
extension DatabaseManager{
    //the completion handler because the function of actually get data out of data base is asynchoronous  so we need a completion block
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)){
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    /// insert new user to database
    public func insertUser(with user: ChatAppUser){
        database.child(user.safeEmail).setValue([
            "name": user.name,
            "mobile": user.mobile
        
        ])
    }
}

struct ChatAppUser{
    let name: String
    let email: String
    let mobile: String
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
//    let profilePictureUrl: String
}
