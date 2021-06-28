import Vapor
import MongoKitten

final class BotSessionServices {
    let threadPool: NIOThreadPool
    let dateProvider: DateProvider
    let mongoDB: MongoDatabase
    let logger: Logger

    init(threadPool: NIOThreadPool, dateProvider: DateProvider, mongoDB: MongoDatabase, logger: Logger) {
        self.threadPool = threadPool
        self.dateProvider = dateProvider
        self.mongoDB = mongoDB
        self.logger = logger
    }
}
