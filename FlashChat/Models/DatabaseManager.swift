//
//  DatabaseManager.swift
//  FlashChat
//
//  Created by mac on 13/09/2023.
//

import Foundation
import FirebaseDatabase
import MessageKit
import CoreLocation

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAdress: String) -> String {
        var safeEmail = emailAdress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

extension DatabaseManager {
    //this method is to get the user name to put it in the chat of users in case of login with email and pass in LoginVC
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DataBaseErrors.faildToFetch))
                return
            }
            completion(.success(value))
        }
    }
}
//MARK: - Account managment
extension DatabaseManager{
    //the completion handler because the function of actually get data out of data base is asynchoronous  so we need a completion block
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)){
        
        let safeEmail = DatabaseManager.safeEmail(emailAdress: email)
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    //insert new user to database
    public func insertUser(with users: ChatAppUser, completion: @escaping (Bool) -> Void){
        database.child(users.safeEmail).setValue([
            "first_name": users.firstName,
            "last_name": users.lastName
        ], withCompletionBlock: { [weak self] error, _ in
            guard let strongSelf = self else{
                return
            }
            
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
            strongSelf.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                //the reason of let var not if let is thet var makes it immutable and we want to append more content to array and update it
                if var usersCollection = snapshot.value as? [[String: String]] {
                    //Append to users dictionary
                    let newElemnt =
                    [
                        "name": users.firstName + " " + users.lastName ,
                        "email": users.safeEmail
                    ]
                    
                    usersCollection.append(newElemnt)
                    
                    strongSelf.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                        
                    })
                    
                } else {
                    //Create that array
                    let newCollection: [[String: String]] = [
                        [
                            "name": users.firstName + " " + users.lastName ,
                            "email": users.safeEmail
                        ]
                    ]
                    
                    strongSelf.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
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

//MARK: - Sending messages / conversations
extension DatabaseManager{
    /*
     
     "sdvvms" {
     "messages": [
     {
     "id": String,
     "type": text, photo, video,
     "content": String,
     "date": Date(),
     "sender_email": String,
     "isRead": true/false,
     
     }
     ]
     }
     
     conversation => [
     [
     
     "conversation_id": "sdvvms"
     "other_user_email":
     "latest_message": => {
     "dare":Date()
     "latest_message": "message"
     "is_read": true/ false
     
     }
     ],
     ]
     */
    
    /// Creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool)-> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String else{
            return
        }
        
        
        let safeEmail = DatabaseManager.safeEmail(emailAdress: currentEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else{
                completion(false)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatsVC.dateFormatter.string(from: messageDate)
            
            var message = ""
            switch firstMessage.kind {
                
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            let recipient_newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": safeEmail,
                "name": currentName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            //Update recipiant conversation entry
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    //append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                    
                }
                else {
                    //create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })
            
            //Update current user conversation entry
            
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                //conversation array exists for current user
                //you should append
                
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self?.finihCraetingConversation(name: name, conversationId: conversationId, firstMessage: firstMessage, completion: completion)
                })
            } else {
                // conversation array does not exist
                //create it
                userNode["conversations"] = [
                    newConversationData
                ]
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self?.finihCraetingConversation(name: name, conversationId: conversationId, firstMessage: firstMessage, completion: completion)
                })
            }
        })
    }
    
    private func finihCraetingConversation(name: String, conversationId: String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        //        {
        //         "id": String,
        //         "type": text, photo, video,
        //         "content": String,
        //         "date": Date(),
        //         "sender_email": String,
        //         "isRead": true/false,
        //        }
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatsVC.dateFormatter.string(from: messageDate)
        
        var message = ""
        switch firstMessage.kind {
            
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            completion(false)
            return
        }
        let currentUserEmail = DatabaseManager.safeEmail(emailAdress: myEmail)
        
        let collectionMessage: [String: Any] = [
            
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail ,
            "is_read": false,
            "name": name
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        database.child("\(conversationId)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
        
    }
    /// Featches and return all conversations for the user with passed in email
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation],Error>) -> Void) {
        database.child("\(email)/conversations").observe( .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DataBaseErrors.faildToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        isRead: isRead)
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latesMessage: latestMessageObject)
            })
            completion(.success(conversations))
        })
    }
    /// Gets all messages for a given  conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) ->  Void) {
        database.child("\(id)/messages").observe( .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DataBaseErrors.faildToFetch))
                return
            }
            let messages: [Message] = value.compactMap({ dictionary in
                
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatsVC.dateFormatter.date(from: dateString) else {
                    return nil
                }
                
                var kind: MessageKind?
                if type == "photo" {
                    //if the type is photo
                    guard let imageUrl = URL(string: content),
                          let placeHoledr = UIImage(systemName: "plus") else {
                        return nil
                    }
                    let media = Media( url: imageUrl,
                                       image: nil,
                                       placeholderImage: placeHoledr,
                                       size: CGSize(width: 300, height: 300))
                    kind = .photo(media)
                }
                else if type == "video" {
                    //if the type is video
                    guard let videoUrl = URL(string: content),
                          let placeHoledr = UIImage(named: "video_placeholder") else {
                        return nil
                    }
                    let media = Media( url: videoUrl,
                                       image: nil,
                                       placeholderImage: placeHoledr,
                                       size: CGSize(width: 300, height: 300))
                    kind = .video(media)
                }
                
                else if type == "location" {
                    let locationComponent = content.components(separatedBy: ",")
                    guard let longitude = Double(locationComponent[0]) ,  let latitude = Double(locationComponent[1]) else {
                        return nil
                    }
                    
                    let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                            size: CGSize(width: 300, height: 300))
                    kind = .location(location)
                }
                else {
                    kind = .text(content)
                }
                
                guard let finalKind = kind else {
                    return nil
                }
                
                let sender = Sender(photoURL: "",
                                    senderId: senderEmail,
                                    displayName: name)
                
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: finalKind)
                
//                return Message(sender: sender,
//                               messageId: messageID,
//                               sentDate: date,
//                               kind: finalKind)
            })
            completion(.success(messages))
        })
        
    }
    /// Send a message with target conversation and message
    public func sendMessage(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        //1- add new message to messages
        //2- update sender latest message
        //3- update recipiant latest message
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let currentEmail = DatabaseManager.safeEmail(emailAdress: myEmail)
        database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else{
                return
            }
            
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatsVC.dateFormatter.string(from: messageDate)
            
            var message = ""
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetURLString = mediaItem.url?.absoluteString {
                    message = targetURLString
                }
                break
            case .video(let mediaItem):
                if let targetURLString = mediaItem.url?.absoluteString {
                    message = targetURLString
                }
                break
            case .location(let locationData):
                let location = locationData.location
                message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else{
                completion(false)
                return
            }
            let currentUserEmail = DatabaseManager.safeEmail(emailAdress: myEmail)
            
            let newMessageEntry: [String: Any] = [
                
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail ,
                "is_read": false,
                "name": name
            ]
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else{
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    
                    var databaseEntryConversations = [[String: Any]]()
                    
                    let updatedValue: [String: Any] =
                    [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    if var currentUserConversations = snapshot.value as? [[String: Any]] {
                        var targetConversation: [String: Any]?
                        var position = 0
                        
                        for conversationDictionary in currentUserConversations {
                            if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                targetConversation = conversationDictionary
                                break
                            }
                            position += 1
                        }
                        if var targetConversation = targetConversation{
                            
                            targetConversation["latest_message"] = updatedValue
                            currentUserConversations[position] = targetConversation
                            databaseEntryConversations = currentUserConversations
                        }
                        else {
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "other_user_email": DatabaseManager.safeEmail(emailAdress: otherUserEmail),
                                "name": name,
                                "latest_message": updatedValue
                            ]
                            currentUserConversations.append(newConversationData)
                            databaseEntryConversations = currentUserConversations
                        }
                    }
                    else {
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_email": DatabaseManager.safeEmail(emailAdress: otherUserEmail),
                            "name": name,
                            "latest_message": updatedValue
                        ]
                        databaseEntryConversations = [
                            newConversationData
                        ]
                    }
                    
                    strongSelf.database.child("\(currentEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        //update latest message for recipiant user
                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]
                            var databaseEntryConversations = [[String: Any]]()
                            
                            guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                                return
                            }
                            
                            if var otherUserConversations = snapshot.value as? [[String: Any]] {
                                
                                var targetConversation: [String: Any]?
                                var position = 0
                                
                                for conversationDictionary in otherUserConversations {
                                    if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                        targetConversation = conversationDictionary
                                        break
                                    }
                                    position += 1
                                }
                                
                                if var targetConversation = targetConversation {
                                    targetConversation["latest_message"] = updatedValue
                                    otherUserConversations[position] = targetConversation
                                    databaseEntryConversations = otherUserConversations
                                }
                                else {
                                    //Failed to  find in current colection
                                    let newConversationData: [String: Any] = [
                                        "id": conversation,
                                        "other_user_email": DatabaseManager.safeEmail(emailAdress: currentEmail),
                                        "name": currentName,
                                        "latest_message": updatedValue
                                    ]
                                    otherUserConversations.append(newConversationData)
                                    databaseEntryConversations = otherUserConversations
                                }
                                
                            }
                            else {
                                //current collection does not exist
                                let newConversationData: [String: Any] = [
                                    "id": conversation,
                                    "other_user_email": DatabaseManager.safeEmail(emailAdress: currentEmail),
                                    "name": currentName,
                                    "latest_message": updatedValue
                                ]
                                databaseEntryConversations = [
                                    newConversationData
                                ]
                            }

                            strongSelf.database.child("\(otherUserEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                completion(true)
                            })
                        })
                    })
                })
                
                completion(true)
            }
        })
    }
    
    public func deleteConversation(conversationId: String , completion: @escaping (Bool) -> Void ) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAdress: email)
        print("Deleting conversation with id \(conversationId)")
        //get all conversations for current user
        //delete conversation in collection with target id
        //reset those conversations for the user database
        let ref = database.child("\(safeEmail)/conversations")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if var conversations = snapshot.value as? [[String: Any]] {
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String,
                       id == conversationId {
                        print("found conversation to delete")
                        break
                    }
                    positionToRemove += 1
                }
                
                conversations.remove(at: positionToRemove)
                ref.setValue(conversations, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        print("failed to delete conversations array")
                        return
                    }
                    print("deleted conversations")
                    completion(true)
                })
            }
        })
    }
    
    public func conversationExists(with targetRecipiantEmail: String, completion: @escaping (Result<String, Error>) -> Void) {
        let safeRecipiantEmail = DatabaseManager.safeEmail(emailAdress: targetRecipiantEmail)
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeSenderEmail = DatabaseManager.safeEmail(emailAdress: senderEmail)
        
        database.child("\(safeRecipiantEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else {
                completion(.failure(DataBaseErrors.faildToFetch))
                return
            }
            //iterate and find conversation with target snder
            if let conversaion = collection.first(where: {
                guard let targetSenderEmail = $0["other_user_email"] as? String else {
                    return false
                }
                return safeSenderEmail == targetSenderEmail
            }) {
                //get id
                guard let id = conversaion["id"] as? String else {
                    completion(.failure(DataBaseErrors.faildToFetch))
                    return
                }
                completion(.success(id))
                return
            }
            completion(.failure(DataBaseErrors.faildToFetch))
            return
        })
    }
}





struct ChatAppUser{
    let firstName: String
    let email: String
    let lastName: String
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
