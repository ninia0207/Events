//
//  AuthManager.swift
//  Events
//
//  Created by Ninia Sabadze on 09.02.24.
//

import FirebaseDatabase
import FirebaseAuth

public class AuthManager{
    
    static let shared = AuthManager()
    
    public func registerNewUser(username: String, email: String, password: String, completion: @escaping (Bool) -> Void){
        DatabaseManager.shared.canCreateNewUser(with: email, username: username) {canCreate in
            
            if canCreate{
                Auth.auth().createUser(withEmail: email, password: password) {result, error in
                    
                    guard error == nil, result != nil else{
                        //Firebase auth could not create account
                        return
                    }
                    
                    //insert into database
                    DatabaseManager.shared.insertNewUser(with: email, username: username) {inserted in
                        if inserted{
                            completion(true)
                            return
                        }else{
                            //failed to insert to database
                            completion(false)
                            return
                        }
                    }
                }
            }
            else{
                //either username or email doesn't exist
            }
        }
    }
    
    //we're using completion inside another closure and as a result scope needs to escape
    public func logInUser(username: String?, email: String?, password: String, completion: @escaping (Bool) -> Void){
        
        if let email = email{
            //email log in
            Auth.auth().signIn(withEmail: email, password: password) {(authResult, error) in
                if let error = error {
                    //completion(.failure(error))
                    completion(false)
                    return
                }
                completion(true)
//                guard let user = authResult?.user else {
//                    print("Error getting user data from Auth.auth()")
//                    return
//                }
//                
//                //completion(.success(user))
//                DatabaseManager.shared.fetchUser(userEmail: email) { user in
//                    completion(.success(user))
//                }
            
            }
            
        }
    }
    
    ///Attempt to log out firebase user
    public func logOut(completion: (Bool) -> Void){
        do{
            try Auth.auth().signOut()
            completion(true)
            return
        }
        catch{
            print(error)
            completion(false)
            return
        }
    }
    
}
