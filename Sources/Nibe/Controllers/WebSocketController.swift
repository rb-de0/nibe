import Vapor
import MongoKitten

final class WebSocketController {

    func shouldUpgrade(request: Request) -> EventLoopFuture<HTTPHeaders?> {
        if request.application.environment == .production {
            let origin = request.headers[.origin].first
            if origin != request.application.configuration.server.origin {
                return request.eventLoop.makeFailedFuture(Abort(.badRequest))
            }
        }
        guard request.application.webSocketClientPool.canRegister() else {
            return request.eventLoop.makeFailedFuture(Abort(.serviceUnavailable))
        }
        do {
            let ticket = try request.query.get(String.self, at: "ticket")
            let tickets = request.mongoDB[Ticket.collectionName]
            return tickets.findOne("token" == ticket, as: Ticket.self)
                .flatMap { ticket -> EventLoopFuture<Session?> in
                    if let ticket = ticket {
                        let sessions = request.mongoDB[Session.collectionName]
                        return sessions.findOne("_id" == ticket.sessionID, as: Session.self)
                    } else {
                        return request.eventLoop.makeSucceededFuture(nil)
                    }
                }
                .map { session -> HTTPHeaders? in
                    if let session = session {
                        request.auth.login(session)
                        return [:]
                    } else {
                        return nil
                    }
                }
        } catch {
            return request.eventLoop.makeSucceededFuture(nil)
        }
    }

    func onUpgrade(request: Request, webSocket: WebSocket) {
        do {
            let session = try request.auth.require(Session.self)
            let client = WebSocketClient(application: request.application,
                                         webSocket: webSocket,
                                         session: session)
            request.application.webSocketClientPool.register(client: client)
        } catch {
            _ = webSocket.close(code: .policyViolation)
        }
    }
}
