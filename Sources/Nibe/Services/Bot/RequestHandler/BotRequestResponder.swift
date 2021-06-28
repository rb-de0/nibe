import Vapor

protocol BotRequestResponder {
    func respond(request: BotRequestResponderRequest, with context: BotSessionContext) -> EventLoopFuture<BotRequestHandlerCompleteAction>
}
