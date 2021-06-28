import Vapor

struct BotEmptyResponder: BotRequestResponder {
    func respond(request: BotRequestResponderRequest, with context: BotSessionContext) -> EventLoopFuture<BotRequestHandlerCompleteAction> {
        return context.eventLoop.makeSucceededFuture(.noAction)
    }
}
