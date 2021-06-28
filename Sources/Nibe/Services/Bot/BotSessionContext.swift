import Vapor
import MongoKitten

final class BotSessionContext {

    let services: BotSessionServices
    let dictionaries: BotDictionaries
    let eventLoop: EventLoop
    let socket: BotSessionSocket
    let data: BotSessionData
    let sessionID: String

    init(services: BotSessionServices,
         dictionaries: BotDictionaries,
         eventLoop: EventLoop,
         socket: BotSessionSocket,
         data: BotSessionData,
         sessionID: String) {
        self.services = services
        self.dictionaries = dictionaries
        self.eventLoop = eventLoop
        self.socket = socket
        self.data = data
        self.sessionID = sessionID
    }

    deinit {
        services.logger.debug("BotSessionContext deinit")
    }
}

extension BotSessionContext {
    enum Error: Swift.Error {
        case sessionNotFound
    }

    func readSession() -> EventLoopFuture<Session> {
        let sessions = services.mongoDB[Session.collectionName]
        return sessions.findOne("_id" == sessionID, as: Session.self)
            .unwrap(or: Error.sessionNotFound)
    }
}
