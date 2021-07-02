import Vapor

protocol ConversationMatchResolver {
    func resolve(message: String, tokens: [BotMessageToken], in eventLoop: EventLoop) -> EventLoopFuture<ConversationResolveResult>
}

final class DefaultConversationMatchResolver: ConversationMatchResolver {

    private let threadPool: NIOThreadPool
    private let similarWordsResolver: SimilarWordsResolver
    private let dictionariesProvider: BotDictionariesProvider

    init(threadPool: NIOThreadPool, similarWordsResolver: SimilarWordsResolver, dictionariesProvider: BotDictionariesProvider) {
        self.threadPool = threadPool
        self.similarWordsResolver = similarWordsResolver
        self.dictionariesProvider = dictionariesProvider
    }

    func resolve(message: String, tokens: [BotMessageToken], in eventLoop: EventLoop) -> EventLoopFuture<ConversationResolveResult> {
        let tokenSet = Set(tokens.map(\.original))
        let conversationDictionary = dictionariesProvider.botDictionaries.conversationDictionary
        let similarWordMatched: EventLoopFuture<(pattern: [BotConversationDictionary.Item], synset: [BotConversationDictionary.Item])>
        if let pickedUpToken = tokenSet.randomElement() {
            similarWordMatched = similarWordsResolver.resolve(word: pickedUpToken, on: eventLoop)
                .recover { _ in [] }
                .flatMap { [threadPool] words -> EventLoopFuture<(pattern: [BotConversationDictionary.Item], synset: [BotConversationDictionary.Item])> in
                    let appended = tokens.map(\.original) + words.flatMap { $0.words }
                    let appendedSet = Set(appended)
                    let synsetsSet = Set(words.flatMap { $0.synsets })
                    let synsetMatched = threadPool.runIfActive(eventLoop: eventLoop) {
                        return conversationDictionary.items.filter { item in
                            !item.synsets.isEmpty && item.synsets.isSubset(of: synsetsSet) == true
                        }
                    }
                    let patternMatched = threadPool.runIfActive(eventLoop: eventLoop) {
                        return conversationDictionary.items.filter { item in
                            item.patterns.contains(where: { pattern in
                                !pattern.isEmpty && pattern.isSubset(of: appendedSet)
                            })
                        }
                    }
                    return patternMatched.and(synsetMatched).map { (pattern: $0.0, synset: $0.1) }
                }
        } else {
            similarWordMatched = eventLoop.makeSucceededFuture(([], []))
        }
        let patternMatched = threadPool.runIfActive(eventLoop: eventLoop) { [conversationDictionary] in
            conversationDictionary.items.filter { item in
                item.patterns.contains(where: { pattern in
                    !pattern.isEmpty && pattern.isSubset(of: tokenSet)
                })
            }
        }
        let textMatched = threadPool.runIfActive(eventLoop: eventLoop) { [conversationDictionary] in
            conversationDictionary.items.filter { item in
                item.textContains.contains(where: {
                    message.contains($0)
                })
            }
        }
        return similarWordMatched
            .and(patternMatched)
            .map { ($0.0.pattern, $0.0.synset, $0.1) }
            .and(textMatched)
            .map { ($0.0.0, $0.0.1, $0.0.2, $0.1) }
            .map { similarWordPatternMatched, similarWordSynsetMatched, patternMatched, textMatched in
                .init(patternMatchedItems: patternMatched,
                      textMatcheditems: textMatched,
                      similarWordPatternMatchedItems: similarWordPatternMatched,
                      similarWordSynsetsMatchedItems: similarWordSynsetMatched)
            }
    }
}

private struct ConversationMatchResolverKey: StorageKey {
    typealias Value = ConversationMatchResolver
}

extension Application {
    var conversationMatchResolver: ConversationMatchResolver {
        get {
            return storage[ConversationMatchResolverKey.self]!
        }
        set {
            storage[ConversationMatchResolverKey.self] = newValue
        }
    }
}
