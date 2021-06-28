import Vapor

struct BotRequest {
    let request: WebSocketRequest
    let message: String?
    let tokens: [BotMessageToken]?
}
