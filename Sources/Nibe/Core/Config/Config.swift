import Vapor

struct Configuration: Decodable {
    let bot: Bot
    let paths: Paths
    let server: Server
}

extension Configuration {
    struct Bot: Decodable {
        let name: String
    }

    struct Paths: Decodable {
        let `public`: String
        let dictionary: String
        let wordnetFile: String
    }

    struct Server: Decodable {
        let origin: String
        let maxClientConnections: Int
        let secureOnly: Bool
        let mongoURI: String
    }
}

private struct ConfigurationKey: StorageKey {
    typealias Value = Configuration
}

extension Application {
    var configuration: Configuration {
        get {
            return storage[ConfigurationKey.self]!
        }
        set {
            storage[ConfigurationKey.self] = newValue
        }
    }
}

extension Request {
    var configuration: Configuration {
        return application.configuration
    }
}
