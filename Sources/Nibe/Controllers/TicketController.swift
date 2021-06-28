import Vapor
import VaporCSRF

final class TicketController {

    func createTicket(request: Request) throws -> EventLoopFuture<WebsocketConnectionToken> {
        try request.csrf.verifyToken()
        let session = try request.auth.require(Session.self)
        let token = try request.connectionTokenGenerator.generateToken()
        let ticket = Ticket(token: token, sessionID: session._id)
        let tickets = request.mongoDB[Ticket.collectionName]
        return tickets.insertEncoded(ticket)
            .flatMapThrowing { reply in
                if reply.writeErrors != nil {
                    throw Abort(.internalServerError)
                }
                return WebsocketConnectionToken(token: ticket.token)
            }
    }
}
