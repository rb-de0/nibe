import Vapor
import NIO

final class BotDictionariesProvider {

    private(set) var botDictionaries: BotDictionaries
    private var task: RepeatedTask?

    init(app: Application) throws {
        self.botDictionaries = try BotDictionaries.load(for: app)
        let eventLoop = app.eventLoopGroup.next()
        let task = eventLoop.scheduleRepeatedAsyncTask(initialDelay: .minutes(60), delay: .minutes(60)) {  _ in
            app.threadPool.runIfActive(eventLoop: eventLoop) {
                try BotDictionaries.load(for: app)
            }
            .map { [weak self] in
                app.logger.info("Refreshed Bot Dictionaries")
                self?.botDictionaries = $0
            }
            .transform(to: ())
        }
        self.task = task
    }

    deinit {
        task?.cancel()
    }
}

private struct BotDictionariesProviderKey: StorageKey {
    typealias Value = BotDictionariesProvider
}

extension Application {
    var botDictionariesProvider: BotDictionariesProvider {
        get {
            return storage[BotDictionariesProviderKey.self]!
        }
        set {
            storage[BotDictionariesProviderKey.self] = newValue
        }
    }
}
