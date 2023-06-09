import Vapor

struct UserGuardMiddleware: AsyncMiddleware {
    
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // Check User ID
        guard let userId = request.headers["USERID"].first
        else {
            throw Abort(.unauthorized, reason: "missing user id")
        }

        guard let user = try await User.find(UUID(uuidString: userId), on: request.db) else {
            throw Abort(.unauthorized, reason: "can not found user")
        }
        
        request.auth.login(user)

        return try await next.respond(to: request)
    }
}
