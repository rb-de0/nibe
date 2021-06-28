struct BotGreetingMessageDictionary: Decodable {
    let items: [Item]
}

extension BotGreetingMessageDictionary {
    struct Item: Decodable {
        let range: TimeRange
        let messages: [String]
    }
}

extension BotGreetingMessageDictionary {
    struct TimeRange: Decodable {
        let start: Int
        let end: Int
    }
}
