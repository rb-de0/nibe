import Vapor

enum WebSocketRequest: Decodable {
    case chat(Chat)

    private enum CodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "chat":
            let chat = try Chat(from: decoder)
            self = .chat(chat)
        default:
            throw DecodeError.invalidMessageType
        }
    }
}

extension WebSocketRequest {
    struct Chat: Decodable {
        let message: String
    }
}

extension WebSocketRequest {
    enum DecodeError: Error {
        case invalidMessageType
        case invalidData
    }
}
