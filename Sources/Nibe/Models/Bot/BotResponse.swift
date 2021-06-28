import Vapor

enum BotResponse {
    case chat(Chat)
    case leave(Leave)
}

extension BotResponse {
    struct Chat {
        let message: String
        let isMine: Bool
    }

    struct Leave {
        let message: String
    }
}
