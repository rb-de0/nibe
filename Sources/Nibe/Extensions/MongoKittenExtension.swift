import Vapor
import MongoKitten

private struct MongoDBStorageKey: StorageKey {
    typealias Value = MongoDatabase
}

extension Application {
    var mongoDB: MongoDatabase {
        get {
            return storage[MongoDBStorageKey.self]!
        }
        set {
            storage[MongoDBStorageKey.self] = newValue
        }
    }

    func initializeMongoDB(connectionString: String) throws {
        mongoDB = try MongoDatabase.connect(connectionString, on: eventLoopGroup).wait()
    }
}

extension Request {
    var mongoDB: MongoDatabase {
        return application.mongoDB.hopped(to: eventLoop)
    }
}
