struct BotConversationDictionary: Decodable {
    let items: [Item]

    func marged(dict: BotConversationDictionary) -> BotConversationDictionary {
        return .init(items: items + dict.items)
    }
}

extension BotConversationDictionary {
    struct Item: Decodable {
        let patterns: [Set<String>]
        let textContains: Set<String>
        let synsets: Set<String>
        let messages: Set<String>
    }
}
