import Vapor
import MongoKitten

protocol BotRequestHandler: AnyObject {
    func handle(request: BotRequest, with context: BotSessionContext) -> EventLoopFuture<BotRequestHandlerCompleteAction>
}

final class DefaultBotRequestHandler: BotRequestHandler {

    private let middlewares: [BotRequestMiddleware]
    private let preprocessor: BotRequestPreprocessor
    private let queue: EventLoopFutureTaskQueue<BotRequestHandlerCompleteAction>

    init(middlewares: [BotRequestMiddleware], preprocessor: BotRequestPreprocessor, eventLoop: EventLoop) {
        self.middlewares = middlewares.reversed()
        self.preprocessor = preprocessor
        self.queue = .init(eventLoop: eventLoop, limit: 5)
    }

    func handle(request: BotRequest, with context: BotSessionContext) -> EventLoopFuture<BotRequestHandlerCompleteAction> {
        var responder: BotRequestResponder = BotEmptyResponder()
        for middleware in middlewares {
            responder = BotRequestMiddlewareResponder(responder: responder, middleware: middleware)
        }
        let executor = BotRequestResponderExecutor()
        return preprocessor.process(request: request, with: context)
            .flatMap { [queue] in
                queue.enqueue {
                    executor.execute(responder: responder, request: request, with: context)
                }
            }
    }
}

private final class BotRequestResponderExecutor {
    func execute(responder: BotRequestResponder, request: BotRequest, with context: BotSessionContext) -> EventLoopFuture<BotRequestHandlerCompleteAction> {
        context.services.logger.debug("Start handling request \(request.request)")
        return context.readSession()
            .flatMap { session in
                let data = BotRequestResponderRequest.Data(session: session)
                let responderRequest = BotRequestResponderRequest(botRequest: request, data: data)
                return responder.respond(request: responderRequest, with: context)
                    .flatMap { action in
                        let sessions = context.services.mongoDB[Session.collectionName]
                        data.session.updatedAt = Date()
                        return sessions.updateEncoded(where: "_id" == context.sessionID, to: data.session)
                            .transform(to: action)
                    }
            }
            .always { _ in
                context.services.logger.debug("Finish handling request \(request.request)")
            }
    }
}

private final class BotRequestMiddlewareResponder: BotRequestResponder {

    private let responder: BotRequestResponder
    private let middleware: BotRequestMiddleware

    init(responder: BotRequestResponder, middleware: BotRequestMiddleware) {
        self.responder = responder
        self.middleware = middleware
    }

    func respond(request: BotRequestResponderRequest, with context: BotSessionContext) -> EventLoopFuture<BotRequestHandlerCompleteAction> {
        return middleware.respond(request: request, with: context, chainingTo: responder)
    }
}
