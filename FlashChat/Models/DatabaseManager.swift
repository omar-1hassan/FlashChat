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
    
    static func safeEmail(emailAdress: String) -> String {
        var safeEmail = emailAdress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
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
    //insert new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue([
            "name": user.name,
            "mobile": user.mobile
            
        ], withCompletionBlock: { error, _ in
            guard error == nil else{
                print("Fialed to write to data base")
                completion(false)
                return
            }

            
            //every time we add a user we're gonna create a new on of these entries
            //this whole array have one root child pointer called users
            //the reson we are doing this is when the user tries to start a conversation we could pull out all these users with just one request
            /*
             users => [
             [
             "name":
             "safe_email":
             ],
             [
             "name":
             "safe_email":
             ]
             ]
             */
            //now what we want to do in this insert uesr is once the user object is crated initily we also want to append it to our users collection
            //first we will try to get a referance to an existing users array if it dosen't exist  when they create it we're gonna append it
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                //the reason of let var not if let is thet var makes it immutable and we want to append more content to array and update it
                if var usersCollection = snapshot.value as? [[String: String]] {
                    //Append to users dictionary
                    let newElemnt =
                    [
                        "name": user.name ,
                        "email": user.safeEmail
                    ]
                    
                    usersCollection.append(newElemnt)
                    
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(true)
                            return
                        }
                        
                        completion(true)
                        
                    })
                    
                } else {
                    //Create that array
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.name ,
                            "email": user.safeEmail
                        ]
                    ]
                    
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
            
            completion(true)
        })
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DataBaseErrors.faildToFetch))
                return
            }
            completion(.success(value))
        })
    }
}
public enum DataBaseErrors: Error{
    case faildToFetch
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
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
