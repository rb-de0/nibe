import Vapor

struct BotDictionaries {
    let greetingMessageDictonary: BotGreetingMessageDictionary
    let conversationDictionary: BotConversationDictionary
    let leaveMessageDictionary: BotLeaveMessageDictionary
    let badwordDictionary: BotBadwordDictionary
    let fallbackDictionary: BotFallbackDictionary
}

extension BotDictionaries {
    static func load(for app: Application) throws -> BotDictionaries {
        let loader = JSONLoader(directory: app.configuration.paths.dictionary)
        let greetingMessage: BotGreetingMessageDictionary = try loader.load(for: app, name: "greeting")
        let leave: BotLeaveMessageDictionary = try loader.load(for: app, name: "leave")
        let badword: BotBadwordDictionary = try loader.load(for: app, name: "badword")
        let fallback: BotFallbackDictionary = try loader.load(for: app, name: "fallback")
        let conversation: BotConversationDictionary = try loader.load(for: app, name: "conversation")
        return .init(
            greetingMessageDictonary: greetingMessage,
            conversationDictionary: conversation,
            leaveMessageDictionary: leave,
            badwordDictionary: badword,
            fallbackDictionary: fallback
        )
    }
}

private struct BotDictionariesKey: StorageKey {
    typealias Value = BotDictionaries
}

extension Application {
    var botDictionaries: BotDictionaries {
        get {
            return storage[BotDictionariesKey.self]!
        }
        set {
            storage[BotDictionariesKey.self] = newValue
        }
    }
}
