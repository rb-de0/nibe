import Vapor
import MongoKitten

struct UserSessionAuthenticator: SessionAuthenticator {

    typealias User = Nibe.Session

    func authenticate(sessionID: User.SessionID, for request: Request) -> EventLoopFuture<Void> {
        let sessions = request.mongoDB[Session.collectionName]
        return sessions.findOne("_id" == sessionID, as: Session.self)
            .map {
                if let user = $0 {
                    request.auth.login(user)
                }
            }
    }

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        if request.auth.has(Session.self) {
            return next.respond(to: request)
        }
        let future: EventLoopFuture<Void>
        if let sessionID = request.session.id {
            future = authenticate(sessionID: sessionID.string, for: request)
        } else {
            future = request.eventLoop.makeSucceededFuture(())
        }
        return future.flatMap { _ in
            return next.respond(to: request)
        }
    }
}
