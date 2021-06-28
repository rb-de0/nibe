import Vapor

enum WebSocketResponse: Encodable {
    case chat(Chat)
    case leave(Leave)

    private enum CodingKeys: String, CodingKey {
        case type
        case isListItem
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .chat(let chat):
            try container.encode("chat", forKey: .type)
            try container.encode(true, forKey: .isListItem)
            try chat.encode(to: encoder)
        case .leave(let leave):
            try container.encode("leave", forKey: .type)
            try container.encode(true, forKey: .isListItem)
            try leave.encode(to: encoder)
        }
    }
}

extension WebSocketResponse {
    struct Chat: Encodable {
        let messageID: String
        let name: String
        let message: String
        let isMine: Bool

        init(message: String, name: String, isMine: Bool) {
            self.messageID = UUID().uuidString
            self.message = message
            self.name = name
            self.isMine = isMine
        }
    }

    struct Leave: Encodable {
        let chat: Chat

        func encode(to encoder: Encoder) throws {
            try chat.encode(to: encoder)
        }
    }
}
