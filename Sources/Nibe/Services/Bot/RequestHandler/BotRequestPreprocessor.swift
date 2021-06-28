import Vapor

protocol BotRequestPreprocessor {
    func process(request: BotRequest, with context: BotSessionContext) -> EventLoopFuture<Void>
}

final class DefaultBotRequestPreprocessor: BotRequestPreprocessor {
    func process(request: BotRequest, with context: BotSessionContext) -> EventLoopFuture<Void> {
        switch request.request {
        case .chat(let chat):
            let response = BotResponse.chat(.init(message: chat.message, isMine: true))
            context.socket.send(response: response)
        }
        return context.eventLoop.makeSucceededVoidFuture()
    }
}
