import Fluent
import Vapor



struct PostController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let posts = routes.grouped([UserGuardMiddleware()]).grouped("posts")
        posts.get(use: index)
        posts.post(use: create)
        posts.group(":postID") { post in
            post.get(use: show)
            post.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> [Post] {
        try await Post.query(on: req.db).all()
    }
    
    func show(req: Request) async throws -> Post {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.badRequest, reason: "Get User Failed.")
        }
        guard let postID = req.parameters.get("postID"), let postUUID = UUID(uuidString: postID) else {
            throw Abort(.badRequest, reason: "Miss ID When Request post.")
        }
        guard let post = try await user.$posts.query(on: req.db)
            .filter(\.$id == postUUID).first() else {
            throw Abort(.notFound)
        }
        
        return post
    }

    func create(req: Request) async throws -> Post {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.badRequest, reason: "Get User Failed.")
        }
        
        let postData = try req.content.decode(PostDTO.self)
        
        let post = Post(content: postData.content)
        
        try await user.$posts.create(post, on: req.db)
        
        return post
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.badRequest, reason: "Get User Failed.")
        }
        
        guard let postID = req.parameters.get("postID"), let postUUID = UUID(uuidString: postID) else {
            throw Abort(.badRequest, reason: "Miss ID When Request post.")
        }
        
        
        guard let post = try await user.$posts.query(on: req.db)
            .filter(\.$id == postUUID).first() else {
            throw Abort(.notFound)
        }
        
        try await post.delete(on: req.db)
        
        return .noContent
    }
}
