//
//  StorageManager.swift
//  Events
//
//  Created by Ninia Sabadze on 09.02.24.
//

import FirebaseDatabase
import FirebaseStorage
import CoreData

public class StorageManager{
    
    static let shared = StorageManager()
    
    private let bucket = Storage.storage().reference()
    
    public enum StorageErrors : Error{
        case failedToUpload
        case failedToGetDownloadURL
    }
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public func uploadEventHeaderImage(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion){
        
        bucket.child("images/\(fileName)").putData(data, metadata: nil, completion: {metadata, error in
            
            guard error == nil else{
                //failed
                print("failed to upload event image to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.bucket.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else{
                    print("failed to get download url from firebase")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
        
    }
    
    public func downloadImageURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void){
        let reference = bucket.child(path)
        reference.downloadURL(completion: {url, error in
            guard let url = url, error == nil else{
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            
            completion(.success(url))
            
        })
    }
    
}
