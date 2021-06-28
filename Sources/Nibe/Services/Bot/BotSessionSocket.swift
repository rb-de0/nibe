protocol BotSessionSocket {
    func send(response: BotResponse)
    func close()
    func onConnect(_ handler: @escaping () -> Void)
    func onRequest(_ handler: @escaping (BotRequest) -> Void)
}

final class BotSessionSocketAdapter: BotSessionSocket {

    private let converter: BotRequestResponseConverter
    private var onRequestHandler: ((BotRequest) -> Void)?
    private var onResponseHandler: ((WebSocketResponse) -> Void)?
    private var onConnectHandler: (() -> Void)?
    private var onCloseHandler: (() -> Void)?

    init(converter: BotRequestResponseConverter) {
        self.converter = converter
    }

    func send(response: BotResponse) {
        let webSocketResponse = converter.convert(response: response)
        onResponseHandler?(webSocketResponse)
    }

    func close() {
        onCloseHandler?()
    }

    func onConnect(_ handler: @escaping () -> Void) {
        self.onConnectHandler = handler
    }

    func onRequest(_ handler: @escaping (BotRequest) -> Void) {
        self.onRequestHandler = handler
    }

    func onResponse(_ handler: @escaping (WebSocketResponse) -> Void) {
        self.onResponseHandler = handler
    }

    func onClose(_ handler: @escaping () -> Void) {
        self.onCloseHandler = handler
    }

    func connected() {
        onConnectHandler?()
    }

    func send(request: WebSocketRequest) {
        if let botRequest = try? converter.convert(request: request) {
            onRequestHandler?(botRequest)
        }
    }
}
