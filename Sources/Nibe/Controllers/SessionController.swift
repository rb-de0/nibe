import Vapor
import SQLiteKit
import VaporCSRF

final class SessionController {

    func getCSRFToken(request: Request) throws -> EventLoopFuture<CSRFToken> {
        let token = request.csrf.storeToken()
        return request.eventLoop.makeSucceededFuture(.init(token: token))
    }
}
