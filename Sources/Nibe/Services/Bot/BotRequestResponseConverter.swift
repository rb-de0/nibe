import Vapor
import MeCab

protocol BotRequestResponseConverter {
    func convert(response: BotResponse) -> WebSocketResponse
    func convert(request: WebSocketRequest) throws -> BotRequest
}

final class DefaultBotRequestResponseConverter: BotRequestResponseConverter {

    private let configuration: Configuration
    private let botMessageTokenzer: BotMessageTokenizer

    init(configuration: Configuration, botMessageTokenzer: BotMessageTokenizer) {
        self.configuration = configuration
        self.botMessageTokenzer = botMessageTokenzer
    }

    func convert(response: BotResponse) -> WebSocketResponse {
        switch response {
        case .chat(let chat):
            return .chat(.init(message: chat.message, name: configuration.bot.name, isMine: chat.isMine))
        case .leave(let leave):
            let chat = WebSocketResponse.Chat(message: leave.message, name: configuration.bot.name, isMine: false)
            return .leave(.init(chat: chat))
        }
    }

    func convert(request: WebSocketRequest) throws -> BotRequest {
        let tokens: [BotMessageToken]?
        let message: String?
        switch request {
        case .chat(let chat):
            message = chat.message
            tokens = try botMessageTokenzer.tokenize(chat.message)
        }
        return .init(request: request, message: message, tokens: tokens)
    }
}
