import Vapor
import NIO

final class BotBadwordMiddleware: BotRequestMiddleware {

    func respond(request: BotRequestResponderRequest, with context: BotSessionContext, chainingTo next: BotRequestResponder) -> EventLoopFuture<BotRequestHandlerCompleteAction> {
        let badwordDictionary = context.dictionaries.badwordDictionary
        if let tokens = request.botRequest.tokens {
            let matchedItem = badwordDictionary.items.first(where: { item in
                tokens.contains(where: { token in item.patterns.contains(token.reading) })
            })
            guard let matchedItem = matchedItem, let message = matchedItem.messages.randomElement() else {
                return next.respond(request: request, with: context)
            }
            let diff = Int.random(in: 0...4)
            context.data.favorabilityRating -= diff
            if context.data.shouldLeave {
                let leaveMessage = context.dictionaries.leaveMessageDictionary.messages.randomElement()
                let message = leaveMessage ?? message
                return context.eventLoop.scheduleTask(in: .milliseconds(Int64.random(in: 500...4000))) {
                    let response = BotResponse.leave(.init(message: message))
                    context.socket.send(response: response)
                }.futureResult.transform(to: .closeConnection)
            } else {
                return context.eventLoop.scheduleTask(in: .milliseconds(Int64.random(in: 500...4000))) {
                    let response = BotResponse.chat(.init(message: message, isMine: false))
                    context.socket.send(response: response)
                }.futureResult.transform(to: .noAction)
            }
        } else {
            return next.respond(request: request, with: context)
        }
    }
}
