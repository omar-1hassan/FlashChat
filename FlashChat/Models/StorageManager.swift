//
//  StorageManager.swift
//  FlashChat
//
//  Created by mac on 14/09/2023.
//

import Foundation
import FirebaseStorage

final class StorageManager{
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    //this typealias is used in the completion in the next function
    public typealias uploadProfilePicture = (Result<String, Error>)-> Void
    
    ///uploads pictures to firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with data: Data , fileName: String, completion: @escaping uploadProfilePicture){
        storage.child("images/\(fileName)").putData(data ,metadata: nil, completion: { metadata, error in
            guard error == nil else{
                //Failed
                print("Failed to upload data to firebase for pictures")
                completion(.failure(StorageErrors.faildToUpload))
                return
            }
            //succesfull in uploading
            self.storage.child("images/\(fileName)").downloadURL(completion: { url , error in
                guard let url = url else{
                    print("Faild to get download url")
                    completion(.failure(StorageErrors.faildToGetDownloadURL))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    /// Upload image that will be sent in conversation message
    public func uploadMessagePhoto(with data: Data , fileName: String, completion: @escaping uploadProfilePicture){
        storage.child("message_images/\(fileName)").putData(data ,metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else{
                //Failed
                print("Failed to upload data to firebase for pictures")
                completion(.failure(StorageErrors.faildToUpload))
                return
            }
            //succesfull in uploading
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url , error in
                guard let url = url else{
                    print("Faild to get download url")
                    completion(.failure(StorageErrors.faildToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    /// Upload video that will be sent in conversation message
    public func uploadMessageVideo(with fileUrl: URL , fileName: String, completion: @escaping uploadProfilePicture){
        storage.child("message_videos/\(fileName)").putFile(from: fileUrl ,metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else{
                //Failed
                print("Failed to upload video to firebase for pictures")
                completion(.failure(StorageErrors.faildToUpload))
                return
            }
            //succesfull in uploading
            self?.storage.child("message_videos/\(fileName)").downloadURL(completion: { url , error in
                guard let url = url else{
                    print("Faild to get download url")
                    completion(.failure(StorageErrors.faildToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    public enum StorageErrors: Error {
        case faildToUpload
        case faildToGetDownloadURL
    }
    //this is going to return  the download url based on a path we give it to put it in the profile picture
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let referanc = storage.child(path)
        referanc.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.faildToGetDownloadURL))
                return
            }
            completion(.success(url))
        })
    }
}
