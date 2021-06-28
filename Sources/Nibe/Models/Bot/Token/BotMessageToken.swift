struct BotMessageToken {
    let category: Category
    let original: String
    let reading: String
}

extension BotMessageToken {
    enum Category: String {
        case noun = "名詞"
        case adjective = "形容詞"
        case verb = "動詞"
        case unknown
    }
}
