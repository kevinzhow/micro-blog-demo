//
//  File.swift
//  
//
//  Created by kevinzhow on 2023/6/9.
//

import Fluent
import Vapor

public final class Post: Model, Content {
    public static let schema = "posts"
    
    @Parent(key: "user_id")
    public var user: User
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "content")
    public var content: String
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?

    public init() { }

    public init(id: UUID? = nil, content: String) {
        self.id = id
        self.content = content
    }
}


struct PostDTO: Content {
    let id: UUID?
    let content: String
    let createdAt: Date?
    
    init(id: UUID? = nil, content: String, createdAt: Date? = nil) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
    }
}
