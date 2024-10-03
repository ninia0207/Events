//
//  DatabaseManager.swift
//  Events
//
//  Created by Ninia Sabadze on 09.02.24.
//

import FirebaseDatabase

public class DatabaseManager{
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
}

//MARK: -Account Management
extension DatabaseManager {
    
    ///Check if username and email is available
    /// - Parameters
    ///     - email: String represeting email
    ///     - usernmae: String represeting username

    public func canCreateNewUser(with email: String, username: String, completion: @escaping (Bool) -> Void){
        completion(true)
//        database.child(email.safeDatabaseKey()).observeSingleEvent(of: .value, with: {snapshot in
//            guard snapshot.value as? String != nil else{
//                completion(false)
//                return
//            }
//            completion(true)
//        })
    }
    
    ///Insert new user data to database
    /// - Parameters
    ///     - email: String represeting email
    ///     - usernmae: String represeting username
    ///     - completion: Async callback for result if database entry succeeded
    public func insertNewUser(with email: String, username: String, completion: @escaping (Bool) -> Void){
        database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            if var usersCollection = snapshot.value as? [[String: String]]{
                //append to use dictionary
                let newElement = [
                    "username": username,
                 "email": email,
                    "role": "norm"
                ]
                usersCollection.append(newElement)
                self.database.child("users").setValue(usersCollection, withCompletionBlock: {error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    
                    completion(true)
                })
            }else{
                //create that array
                let newCollection: [[String: String]] = [
                    [
                        "username": username,
                        "email": email,
                        "role": "norm"
                    ]
                ]
                self.database.child("users").setValue(newCollection, withCompletionBlock: {error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    completion(true)
                })
            }
        })
        
    }
    
    ///Update User Data
    public func updateUserData(with user: User, completion: @escaping (Bool) -> Void){
        database.child(user.email.safeDatabaseKey()).setValue([
            "username": user.username,
            "email": user.email,
            "role": "norm"
        ] as [String : Any]){error, _ in
            if error == nil{
                //succeeded
                completion(true)
                return
            }else{
                //failed
                completion(false)
                return
            }
        }
    }
    
    public func fetchUser(userEmail: String, completion: @escaping (User) -> Void) {
        let userRef = database.child("users").child(userEmail)
        
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let userDict = snapshot.value as? [String: Any],
               let username = userDict["username"] as? String,
               let email = userDict["email"] as? String,
               let role = userDict["role"] as? String {
                let user = User(username: username, email: email, role: role)
                completion(user)
            }
        }
    }
    
    ///fetch events data
    public func fetchEventsData(completion: @escaping ([Event]) -> Void){
        database.child("events").observe(.value, with: { (snapshot) in
                var events = [Event]()
                guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
                for snap in snapshot {
                    if let eventData = snap.value as? [String: Any],
                       let eventID = eventData["id"] as? String,
                       let title = eventData["title"] as? String,
                       let imageURLString = eventData["URL"] as? String,
                       let description = eventData["description"] as? String,
                       let dateString = eventData["date"] as? String,
                        let attending = eventData["attending"] as? Int
                    {
                        let event = Event(id: eventID, title: title, ImageURL: imageURLString, description: description, date: dateString, attending: attending)
                        events.append(event)
                    }
                }
            completion(events)
            }) { (error) in
                print("Error fetching events")
                completion([])
            }
    }
    
    public func isAdmin(email: String, completion: @escaping (Bool) -> Void) {
        
        let query = database.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email)
        
        query.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                let childSnap = child as! DataSnapshot
                let dict = childSnap.value as! [String: Any]
                let admin = dict["role"] as! String
                
                if admin == "admin" {
                    completion(true)
                }else{
                    completion(false)
                }
            }
        })
    }
    
    ///insert new event in database
    public func insertNewEvent(with event: Event, completion: @escaping (Bool) -> Void){
        database.child("events").observeSingleEvent(of: .value, with: {(snapshot) in
            if var eventsCollection = snapshot.value as? [Dictionary<String, Any>]{
                
                let newElement = [
                    "id": event.id,
                    "URL": event.ImageURL,
                    "date": event.date,
                    "description": event.description,
                    "title": event.title,
                    "attending": 0
                ]
                
                eventsCollection.append(newElement)
                self.database.child("events").setValue(eventsCollection, withCompletionBlock: {error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    
                    completion(true)
                })
                
            }else{
                //create that array
                let newCollection: [[String: Any]] = [
                    [
                        "id": event.id,
                        "URL": event.ImageURL,
                        "date": event.date,
                        "description": event.description,
                        "title": event.title,
                        "attending": 0
                    ]
                ]
                self.database.child("events").setValue(newCollection, withCompletionBlock: {error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    
                    completion(true)
                })
            }
        })
        
        
    }
    
    public func incrementAttend(event: Event, completion: @escaping (Error?) -> Void) {
        let query = database.child("events").queryOrdered(byChild: "id").queryEqual(toValue: event.id)
        
        query.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                let childSnap = child as! DataSnapshot
                let dict = childSnap.value as! [String: Any]
                let id = dict["id"] as! String
                if id == event.id {
                    let updates = [
                        "title": event.title,
                        "ImageURL": event.ImageURL,
                        "description": event.description,
                        "date": event.date,
                        "attending": event.attending + 1
                    ] as [String : Any]
                    childSnap.ref.updateChildValues(updates, withCompletionBlock: { error, _ in
                        completion(error)
                    })
                    break
                }
            }
        })
    }
    
    public func updateEvent(event: Event, completion: @escaping (Error?) -> Void) {
        let query = database.child("events").queryOrdered(byChild: "id").queryEqual(toValue: event.id)
        
        query.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                let childSnap = child as! DataSnapshot
                let dict = childSnap.value as! [String: Any]
                let id = dict["id"] as! String
                if id == event.id {
                    let updates = [
                        "title": event.title,
                        "ImageURL": event.ImageURL,
                        "description": event.description,
                        "date": event.date,
                        "attending": event.attending
                    ] as [String : Any]
                    childSnap.ref.updateChildValues(updates, withCompletionBlock: { error, _ in
                        completion(error)
                    })
                    break
                }
            }
        })
    }
    
    public func deleteEvent(id: String, completion: @escaping (Error?) -> Void) {
        let query = database.child("events").queryOrdered(byChild: "id").queryEqual(toValue: id)

        query.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                let childSnap = child as! DataSnapshot
                let dict = childSnap.value as! [String: Any]
                let id = dict["id"] as! String
                if id == id {
                    childSnap.ref.removeValue(completionBlock: { error, _ in
                        completion(error)
                    })
                    break
                }
            }
        })
    }
}
