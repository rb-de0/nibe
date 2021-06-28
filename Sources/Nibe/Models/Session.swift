import Vapor
import MongoKitten

// swiftlint:disable identifier_name
struct Session: Codable {

    static let collectionName = "sessions"

    let _id: String
    var data: [String: String]
    var lastChatMessage: ChatMessage?
    var updatedAt: Date

    init(id: String) {
        self._id = id
        self.data = [:]
        self.lastChatMessage = nil
        self.updatedAt = Date()
    }
}

extension Session {
    struct ChatMessage: Codable {
        let message: String
        let tokens: [ChatMessageToken]
    }

    struct ChatMessageToken: Codable {
        let category: String
        let original: String
        let reading: String
    }
}

extension Session: SessionAuthenticatable {
    var sessionID: String {
        return _id
    }
}
