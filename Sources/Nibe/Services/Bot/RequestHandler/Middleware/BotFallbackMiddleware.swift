import Vapor
import NIO

final class BotFallbackMiddleware: BotRequestMiddleware {

    private let conversationMatchResolver: ConversationMatchResolver

    init(conversationMatchResolver: ConversationMatchResolver) {
        self.conversationMatchResolver = conversationMatchResolver
    }

    func respond(request: BotRequestResponderRequest, with context: BotSessionContext, chainingTo next: BotRequestResponder) -> EventLoopFuture<BotRequestHandlerCompleteAction> {
        let fallbackDictionary = context.dictionaries.fallbackDictionary
        guard let chatMessage = request.data.session.lastChatMessage else {
            if let message = fallbackDictionary.messages.randomElement() {
                return context.eventLoop.scheduleTask(in: .milliseconds(Int64.random(in: 500...4000))) {
                    let response = BotResponse.chat(.init(message: message, isMine: false))
                    context.socket.send(response: response)
                }.futureResult.transform(to: .noAction)
            } else {
                return next.respond(request: request, with: context)
            }
        }
        let message = chatMessage.message
        let tokens = chatMessage.tokens.map {
            BotMessageToken(category: .init(rawValue: $0.category) ?? .unknown, original: $0.original, reading: $0.reading)
        }
        return conversationMatchResolver.resolve(message: message, tokens: tokens, in: context.eventLoop)
            .map { result -> String? in
                let patternMatched = result.patternMatchedItems.randomElement()?.messages.randomElement()
                let textMatched = result.textMatcheditems.randomElement()?.messages.randomElement()
                let similarWordPatternMatched = result.similarWordPatternMatchedItems.randomElement()?.messages.randomElement()
                let similarWordSynsetMatched = result.similarWordSynsetsMatchedItems.randomElement()?.messages.randomElement()
                let similarWordMatched = similarWordPatternMatched ?? similarWordSynsetMatched
                return patternMatched ?? textMatched ?? similarWordMatched
            }
            .flatMap { message in
                if let message = message {
                    let shouldRemoveLastMessage = Int.random(in: 1...2) == 1
                    if shouldRemoveLastMessage {
                        request.data.session.lastChatMessage = nil
                    }
                    return context.eventLoop.scheduleTask(in: .milliseconds(Int64.random(in: 1000...8000))) {
                        let resposne = BotResponse.chat(.init(message: message, isMine: false))
                        context.socket.send(response: resposne)
                    }.futureResult.transform(to: .noAction)
                } else if let message = fallbackDictionary.messages.randomElement() {
                    return context.eventLoop.scheduleTask(in: .milliseconds(Int64.random(in: 500...4000))) {
                        let response = BotResponse.chat(.init(message: message, isMine: false))
                        context.socket.send(response: response)
                    }.futureResult.transform(to: .noAction)
                } else {
                    return next.respond(request: request, with: context)
                }
            }
    }
}
