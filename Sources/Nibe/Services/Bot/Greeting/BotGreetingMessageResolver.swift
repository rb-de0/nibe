import Vapor

protocol BotGreetingMessageResolver: AnyObject {
    func resolve(for eventLoop: EventLoop) -> EventLoopFuture<String?>
}

final class DefaultBotGreetingMessageResolver: BotGreetingMessageResolver {

    private let greetingMessageDictonary: BotGreetingMessageDictionary
    private let dateProvider: DateProvider

    init(greetingMessageDictonary: BotGreetingMessageDictionary, dateProvider: DateProvider) {
        self.greetingMessageDictonary = greetingMessageDictonary
        self.dateProvider = dateProvider
    }

    func resolve(for eventLoop: EventLoop) -> EventLoopFuture<String?> {
        let hour = dateProvider.calender().component(.hour, from: dateProvider.date())
        let item = greetingMessageDictonary.items.first(where: { item in
            if item.range.start >= item.range.end { return false }
            return (item.range.start...item.range.end).contains(hour)
        })
        let message = item?.messages.randomElement()
        return eventLoop.makeSucceededFuture(message)
    }
}
