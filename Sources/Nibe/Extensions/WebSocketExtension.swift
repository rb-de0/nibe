import Vapor

extension WebSocket {
    func send(response: WebSocketResponse) {
        guard let text = try? WebSocketResponseEndoder().encode(response: response) else {
            return
        }
        send(text)
    }
}
