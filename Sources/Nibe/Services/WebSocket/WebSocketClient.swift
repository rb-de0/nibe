import Vapor
import MongoKitten

protocol WebSocketClientDelegate: AnyObject {
    func webSocketClientDidClose(client: WebSocketClient)
}

final class WebSocketClient {

    private let application: Application
    private let webSocket: WebSocket
    private let uuid: UUID
    private let botSession: BotSession
    private let socketAdapter: BotSessionSocketAdapter

    weak var delegate: WebSocketClientDelegate?

    init(application: Application, webSocket: WebSocket, session: Session) {
        self.application = application
        self.webSocket = webSocket
        self.uuid = UUID()
        let converter = DefaultBotRequestResponseConverter(
            configuration: application.configuration,
            botMessageTokenzer: MeCabTokenizer()
        )
        self.socketAdapter = BotSessionSocketAdapter(converter: converter)
        socketAdapter.onResponse {
            webSocket.send(response: $0)
        }
        socketAdapter.onClose {
            webSocket.close().whenSuccess({})
        }
        let services = BotSessionServices(
            threadPool: application.threadPool,
            dateProvider: application.dateProvider,
            mongoDB: application.mongoDB.hopped(to: webSocket.eventLoop),
            logger: application.logger
        )
        let context = BotSessionContext(
            services: services,
            dictionaries: application.botDictionaries,
            eventLoop: webSocket.eventLoop,
            socket: socketAdapter,
            data: .default,
            sessionID: session._id
        )
        let requestHanlder = DefaultBotRequestHandler(
            middlewares: application.botRequestMiddlewares.middlewares,
            preprocessor: DefaultBotRequestPreprocessor(),
            eventLoop: webSocket.eventLoop
        )
        let greetingMessageResolver = DefaultBotGreetingMessageResolver(
            greetingMessageDictonary: application.botDictionaries.greetingMessageDictonary,
            dateProvider: application.dateProvider
        )
        self.botSession = BotSession(
            requestHanlder: requestHanlder,
            greetingMessageResolver: greetingMessageResolver,
            context: context
        )
        webSocket.onClose.whenSuccess { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.webSocketClientDidClose(client: strongSelf)
        }
    }

    func listen() {
        webSocket.pingInterval = .seconds(60)
        webSocket.onText { [weak self] _, text in
            guard let request = try? WebSocketRequestDecoder().decode(text: text) else { return }
            self?.socketAdapter.send(request: request)
        }
        socketAdapter.connected()
    }

    deinit {
        application.logger.debug("WebSocketClient deinit")
        if !webSocket.isClosed {
            webSocket.close().whenSuccess({})
        }
    }
}

extension WebSocketClient: Equatable {
    static func == (lhs: WebSocketClient, rhs: WebSocketClient) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
