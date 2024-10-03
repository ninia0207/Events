//
//  Models.swift
//  Events
//
//  Created by Ninia Sabadze on 13.02.24.
//

import Foundation
import FirebaseAuth

public struct User{
    var username: String
    var email: String
    var role: String
}
//public var currentUser: User = User(username: "", email: "", role: "")

public struct Event {
    let id: String
    let title: String
    let ImageURL: String
    let description: String
    let date: String
    var attending: Int
}

public var models: [Event] = []
public var currentUser = Auth.auth().currentUser

public let defaultImageURL : String = "https://media.istockphoto.com/id/1147544807/vector/thumbnail-image-vector-graphic.jpg?s=612x612&w=0&k=20&c=rnCKVbdxqkjlcs3xH87-9gocETqpspHFXu5dIGB4wuM="
