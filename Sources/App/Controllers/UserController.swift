//
//  File.swift
//  
//
//  Created by kevinzhow on 2023/6/9.
//

import Fluent
import Vapor

/// Provide CURD of the ``User``
///
/// ## Topic
///
/// ### CURD
///
/// - ``create(req:)``
/// - ``show(req:)``
/// - ``index(req:)``
/// - ``delete(req:)``
public struct UserController: RouteCollection {
    public func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
        users.post(use: create)
        users.group(":userID") { user in
            user.get(use: show)
            user.delete(use: delete)
        }
    }
    
    /// Get all users
    ///
    /// Usage
    ///
    /// - Method: GET
    /// - Route: `/users`
    /// - Response: Array of ``User``
    ///
    public func index(req: Request) async throws -> [User] {
        try await User.query(on: req.db).all()
    }
    
    /// Get user by userID
    ///
    /// Usage
    ///
    /// - Method: GET
    /// - Route: `/users/:userID`
    /// - Response: ``User``
    ///
    public func show(req: Request) async throws -> User {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // Load user posts
        try await user.$posts.load(on: req.db)
        
        return user
    }
    
    /// Create user
    ///
    /// Usage
    ///
    /// - Method: POST
    /// - Body: ``User``
    /// - Route: `/users/:userID`
    /// - Response: ``User``
    ///
    public func create(req: Request) async throws -> User {
        let user = try req.content.decode(User.self)
        try await user.save(on: req.db)
        return user
    }
    
    /// Delete user by userID
    ///
    /// Usage
    ///
    /// - Method: DELETE
    /// - Route: `/users/:userID`
    /// - Response: ``HTTPStatus``
    ///
    public func delete(req: Request) async throws -> HTTPStatus {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await user.delete(on: req.db)
        return .noContent
    }
}

