import Vapor
import MongoKitten

protocol BotRequestMiddleware {
    func respond(request: BotRequestResponderRequest, with context: BotSessionContext, chainingTo next: BotRequestResponder) -> EventLoopFuture<BotRequestHandlerCompleteAction>
}

struct BotRequestMiddlewares {

    private(set) var middlewares = [BotRequestMiddleware]()

    mutating func add(_ middleware: BotRequestMiddleware) {
        middlewares.append(middleware)
    }
}

private struct BotBotRequestMiddlewaresKey: StorageKey {
    typealias Value = BotRequestMiddlewares
}

extension Application {
    var botRequestMiddlewares: BotRequestMiddlewares {
        get {
            return storage[BotBotRequestMiddlewaresKey.self]!
        }
        set {
            storage[BotBotRequestMiddlewaresKey.self] = newValue
        }
    }
}

extension Request {
    var botRequestMiddlewares: BotRequestMiddlewares {
        return application.botRequestMiddlewares
    }
}
