import Vapor
import MeCab

protocol BotMessageTokenizer {
    func tokenize(_ text: String) throws -> [BotMessageToken]
}

final class MeCabTokenizer: BotMessageTokenizer {
    func tokenize(_ text: String) throws -> [BotMessageToken] {
        let mecab = try Mecab()
        let nodes = try mecab.tokenize(string: text)
        return nodes.compactMap { node -> BotMessageToken? in
            guard node.features.count == 9 else { return nil }
            let category = BotMessageToken.Category(rawValue: node.features[0]) ?? .unknown
            let original = node.surface
            let reading = node.features[7]
            return .init(category: category, original: original, reading: reading)
        }
    }
}
