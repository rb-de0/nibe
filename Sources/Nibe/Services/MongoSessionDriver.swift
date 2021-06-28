import Vapor
import MongoKitten

final class MongoSessionDriver: SessionDriver {

    func createSession(_ data: SessionData, for request: Request) -> EventLoopFuture<SessionID> {
        let sessions = request.mongoDB[Session.collectionName]
        let sessionID = generateID()
        var session = Session(id: sessionID.string)
        session.data = data.snapshot
        return sessions.insertEncoded(session)
            .transform(to: sessionID)
    }

    func readSession(_ sessionID: SessionID, for request: Request) -> EventLoopFuture<SessionData?> {
        let sessions = request.mongoDB[Session.collectionName]
        return sessions.findOne("_id" == sessionID.string, as: Session.self)
            .map { session in
                session.map { SessionData(initialData: $0.data) }
            }
    }

    func updateSession(_ sessionID: SessionID, to data: SessionData, for request: Request) -> EventLoopFuture<SessionID> {
        let sessions = request.mongoDB[Session.collectionName]
        return sessions
            .updateMany(where: "_id" == sessionID.string, setting: [
                "data": data.snapshot
            ], unsetting: nil)
            .transform(to: sessionID)
    }

    func deleteSession(_ sessionID: SessionID, for request: Request) -> EventLoopFuture<Void> {
        let sessions = request.mongoDB[Session.collectionName]
        return sessions
            .deleteOne(where: "_id" == sessionID.string)
            .transform(to: ())
    }

    private func generateID() -> SessionID {
        let sessionID = [UInt8].random(count: 32).base64
        return .init(string: sessionID)
    }
}
