//
//  File.swift
//  
//
//  Created by kevinzhow on 2023/6/9.
//

import Fluent

struct CreatePost: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Post.schema)
            .id()
            .field("content", .string, .required)
            .field("created_at", .datetime)
            .field("user_id", .uuid, .required, .references(User.schema, "id"))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Post.schema).delete()
    }
}
