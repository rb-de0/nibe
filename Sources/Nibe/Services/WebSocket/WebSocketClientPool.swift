import Vapor
import MongoKitten

final class WebSocketClientPool {

    private var clients: [WebSocketClient] = []
    private let lock = Lock()
    private let maxClientConnnections: Int

    init(maxClientConnnections: Int) {
        self.maxClientConnnections = maxClientConnnections
    }

    func register(client: WebSocketClient) {
        clients.append(client)
        client.delegate = self
        client.listen()
    }

    func canRegister() -> Bool {
        return lock.withLock {
            clients.count < maxClientConnnections
        }
    }
}

extension WebSocketClientPool: WebSocketClientDelegate {
    func webSocketClientDidClose(client: WebSocketClient) {
        lock.withLockVoid {
            if let index = clients.firstIndex(of: client) {
                clients.remove(at: index)
            }
        }
    }
}

private struct WebSocketClientPoolKey: StorageKey {
    typealias Value = WebSocketClientPool
}

extension Application {
    var webSocketClientPool: WebSocketClientPool {
        get {
            return storage[WebSocketClientPoolKey.self]!
        }
        set {
            storage[WebSocketClientPoolKey.self] = newValue
        }
    }
}
