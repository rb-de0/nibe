import Vapor
import MongoKitten

final class BotSession {

    private let requestHanlder: BotRequestHandler
    private let greetingMessageResolver: BotGreetingMessageResolver
    private let context: BotSessionContext

    init(requestHanlder: BotRequestHandler,
         greetingMessageResolver: BotGreetingMessageResolver,
         context: BotSessionContext) {
        self.requestHanlder = requestHanlder
        self.greetingMessageResolver = greetingMessageResolver
        self.context = context
        bind()
    }

    deinit {
        context.services.logger.debug("BotSession deinit")
    }
}

private extension BotSession {
    func bind() {
        context.socket.onConnect { [weak self] in
            self?.onConnect()
        }
        context.socket.onRequest { [weak self] request in
            self?.onRequest(request)
        }
    }

    func onConnect() {
        greetingMessageResolver.resolve(for: context.eventLoop)
            .whenSuccess { [weak self] message in
                guard let message = message else { return }
                let response = BotResponse.chat(.init(message: message, isMine: false))
                self?.context.socket.send(response: response)
            }
    }

    func onRequest(_ request: BotRequest) {
        requestHanlder.handle(request: request, with: context)
            .always { [weak self] result in
                switch result {
                case .failure(let error):
                    switch error {
                    case let contextError as BotSessionContext.Error where contextError == .sessionNotFound:
                        self?.context.socket.close()
                    default:
                        break
                    }
                    self?.context.services.logger.report(error: error)
                default:
                    break
                }
            }
            .whenSuccess { [weak self] action in
                switch action {
                case .noAction:
                    break
                case .closeConnection:
                    self?.context.socket.close()
                }
            }
    }
}
