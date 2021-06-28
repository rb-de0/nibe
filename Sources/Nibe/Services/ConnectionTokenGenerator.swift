import Foundation
import Vapor

protocol ConnectionTokenGenerator {
    func generateToken() throws -> String
}

final class DefaultConnectionTokenGenerator: ConnectionTokenGenerator {
    func generateToken() throws -> String {
        let allowed = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".map { String($0) }
        var token = [String]()
        for _ in 0..<64 {
            allowed.randomElement().map { token.append($0) }
        }
        return token.joined()
    }
}

private struct ConnectionTokenGeneratorKey: StorageKey {
    typealias Value = ConnectionTokenGenerator
}

extension Application {
    var connectionTokenGenerator: ConnectionTokenGenerator {
        get {
            return storage[ConnectionTokenGeneratorKey.self]!
        }
        set {
            storage[ConnectionTokenGeneratorKey.self] = newValue
        }
    }
}

extension Request {
    var connectionTokenGenerator: ConnectionTokenGenerator {
        return application.connectionTokenGenerator
    }
}
