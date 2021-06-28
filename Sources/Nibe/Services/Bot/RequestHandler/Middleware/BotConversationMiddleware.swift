import Vapor
import NIO
import MongoKitten

final class BotConversationMiddleware: BotRequestMiddleware {

    private let conversationMatchResolver: ConversationMatchResolver

    init(conversationMatchResolver: ConversationMatchResolver) {
        self.conversationMatchResolver = conversationMatchResolver
    }

    func respond(request: BotRequestResponderRequest, with context: BotSessionContext, chainingTo next: BotRequestResponder) -> EventLoopFuture<BotRequestHandlerCompleteAction> {
        guard let message = request.botRequest.message, let tokens = request.botRequest.tokens else {
            return next.respond(request: request, with: context)
        }
        return conversationMatchResolver.resolve(message: message, tokens: tokens, in: context.eventLoop)
            .flatMap { result -> EventLoopFuture<BotRequestHandlerCompleteAction> in
                let patternMatched = result.patternMatchedItems.randomElement()?.messages.randomElement()
                let textMatched = result.textMatcheditems.randomElement()?.messages.randomElement()
                let similarWordPatternMatched = result.similarWordPatternMatchedItems.randomElement()?.messages.randomElement()
                let similarWordSynsetMatched = result.similarWordSynsetsMatchedItems.randomElement()?.messages.randomElement()
                let similarWordMatched = similarWordPatternMatched ?? similarWordSynsetMatched
                let message: String?
                if let patternMatched = patternMatched {
                    let value = Int.random(in: 1...100)
                    switch value {
                    case (1...10):
                        message = textMatched ?? patternMatched
                    case (11...20):
                        message = similarWordMatched ?? patternMatched
                    default:
                        message = patternMatched
                    }
                } else {
                    let value = Int.random(in: 1...2)
                    if value % 2 == 0 {
                        message = textMatched ?? similarWordMatched
                    } else {
                        message = similarWordMatched ?? textMatched
                    }
                }
                if let message = message {
                    let chatTokens: [Session.ChatMessageToken] = tokens.map { .init(category: $0.category.rawValue, original: $0.original, reading: $0.reading) }
                    let chatMessage = Session.ChatMessage(message: message, tokens: chatTokens)
                    request.data.session.lastChatMessage = chatMessage
                    return  context.eventLoop.scheduleTask(in: .milliseconds(Int64.random(in: 2000...8000))) {
                        let resposne = BotResponse.chat(.init(message: message, isMine: false))
                        context.socket.send(response: resposne)
                    }.futureResult.transform(to: .noAction)
                } else {
                    return next.respond(request: request, with: context)
                }
            }
    }
}
