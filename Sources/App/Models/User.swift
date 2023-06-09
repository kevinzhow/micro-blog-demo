//
//  File.swift
//  
//
//  Created by kevinzhow on 2023/6/9.
//
import Fluent
import Vapor

public final class User: Model, Content {
    public static let schema = "users"
    
    @Children(for: \.$user)
    public var posts: [Post]
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "username")
    public var username: String
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?

    public init() { }

    public init(id: UUID? = nil, username: String) {
        self.id = id
        self.username = username
    }
}

extension User: Authenticatable {
    
}

struct UserDTO: Content {
    let id: UUID?
    let username: String
    let createdAt: Date?
    
    init(id: UUID? = nil, username: String, createdAt: Date? = nil) {
        self.id = id
        self.username = username
        self.createdAt = createdAt
    }
}
