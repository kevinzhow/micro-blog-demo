@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testCreateUser() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)
        
        // Auto revert will empty the database and remove the schema
        try await app.autoRevert()
        // Auto migrate will recreate database schema
        try await app.autoMigrate()

        let user = UserDTO(username: "kevinzhow")
        
        try app.test(.POST, "users", beforeRequest: { req in
            try req.content.encode(user)
        }, afterResponse: { res in
            let userAccount = try res.content.decode(User.self)
            XCTAssertEqual(userAccount.username, user.username)
        })
    }
    
    func testCreatePost() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)
        
        // Auto revert will empty the database and remove the schema
        try await app.autoRevert()
        // Auto migrate will recreate database schema
        try await app.autoMigrate()

        // Create a user and save it first
        let user = User(username: "kevinzhow")
        try await user.save(on: app.db)
        
        // Create a header with user infos
        let headers: HTTPHeaders = ["USERID": user.id!.uuidString]
        
        let post = PostDTO(content: "Hello World")
        
        try app.test(.POST, "posts", beforeRequest: { req in
            req.headers = headers
            try req.content.encode(post)
        }, afterResponse: { res in
            let createdPost = try res.content.decode(Post.self)
            XCTAssertEqual(createdPost.$user.id, try user.requireID())
            XCTAssertEqual(createdPost.content, post.content)
            XCTAssertNotNil(createdPost.id)
        })
    }
}
