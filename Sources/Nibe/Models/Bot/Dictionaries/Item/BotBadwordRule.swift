struct BotBadwordDictionary: Decodable {
    let items: [Item]
}

extension BotBadwordDictionary {
    struct Item: Decodable {
        let patterns: Set<String>
        let messages: Set<String>
    }
}
