import Vapor
import MongoKitten

struct Ticket: Codable {

    static let collectionName = "tickets"

    let token: String
    let sessionID: String
    let createdAt: Date

    init(token: String, sessionID: String) {
        self.token = token
        self.sessionID = sessionID
        self.createdAt = Date()
    }
}
