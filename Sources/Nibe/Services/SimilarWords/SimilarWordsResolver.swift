import Vapor
import SQLiteKit

enum SimilarWordsResolverError: Error {
    case wordNotFound
}

protocol SimilarWordsResolver {
    func resolve(word: String, on eventLoop: EventLoop) -> EventLoopFuture<[SimilarWords]>
}

final class WordNetSimilarWordsResolver: SimilarWordsResolver {

    private let connectionPool: EventLoopGroupConnectionPool<SQLiteConnectionSource>

    init(application: Application, databasePath: String) {
        let config = SQLiteConfiguration(storage: .file(path: databasePath))
        let source = SQLiteConnectionSource(configuration: config, threadPool: application.threadPool)
        self.connectionPool = .init(source: source, maxConnectionsPerEventLoop: 1, on: application.eventLoopGroup)
    }

    func resolve(word: String, on eventLoop: EventLoop) -> EventLoopFuture<[SimilarWords]> {
        return connectionPool.withConnection(on: eventLoop) { conn in
            let word = conn.sql().select().column("*").from("word")
                .where("lemma", .equal, word)
                .first(decoding: Word.self)
                .unwrap(or: SimilarWordsResolverError.wordNotFound)
            let senses = word.flatMap { word in
                conn.sql().select().column("*").from("sense")
                    .where("wordid", .equal, word.id)
                    .all(decoding: Sense.self)
            }
            let synsets = senses.flatMap { senses -> EventLoopFuture<[(Synset, String)]> in
                let queries = senses.map { sense in
                    conn.sql().select().column("*").from("synset")
                        .where("synset", .equal, sense.synset)
                        .all(decoding: Synset.self)
                        .map { $0.map { ($0, sense.lang) } }
                }
                return EventLoopFuture<[(Synset, String)]>.whenAllSucceed(queries, on: eventLoop)
                    .map { $0.flatMap { $0 } }
            }
            let results = synsets.flatMap { synsets -> EventLoopFuture<[SimilarWords]> in
                let queries = synsets.map { synset -> EventLoopFuture<SimilarWords> in
                    let words = conn.sql().select().column("*").from("sense").from("word")
                        .where("synset", .equal, synset.0.synset)
                        .where(SQLColumn("lang", table: "word"), .equal, SQLLiteral.string(synset.1))
                        .where(SQLColumn("wordid", table: "sense"), .equal, SQLColumn("wordid", table: "word"))
                        .all(decoding: Word.self)
                    return words.flatMap { words -> EventLoopFuture<SimilarWords> in
                        let initial = conn.sql().select().column("*").from("synlink")
                            .where("synset1", .equal, synset.0.synset)
                            .where("link", .equal, "hype")
                            .first(decoding: Synlink.self)
                            .map { synlink in
                                SynlinkNetwork(synlink: synlink, childlen: [synset.0.synset])
                            }
                        return EventLoopFuture<SynlinkNetwork>.sequence(initialFuture: initial) { (linkNet: SynlinkNetwork) in
                            guard let next = linkNet.synlink else { return nil }
                            return conn.sql().select().from("synlink").column("*")
                                .where("synset1", .equal, next.synset2)
                                .where("link", .equal, "hype")
                                .first(decoding: Synlink.self)
                                .map { synlink in
                                    SynlinkNetwork(synlink: synlink, childlen: [next.synset2] + linkNet.childlen)
                                }
                        }
                        .flatMap { network -> EventLoopFuture<[String]> in
                            return conn.sql().select().column("*").from("synset")
                                .where("synset", .in, network.childlen)
                                .all()
                                .map { rows in
                                    rows.compactMap { try? $0.decode(column: "name", as: String.self) }
                                }
                        }
                        .map { SimilarWords(synsets: $0, words: words.map { $0.lemma }) }
                    }
                }
                return EventLoopFuture<SimilarWords>.whenAllSucceed(queries, on: eventLoop)
            }
            return results
        }
    }
}

extension WordNetSimilarWordsResolver {
    struct Word: Decodable {
        let id: Int
        let lang: String
        let lemma: String

        enum CodingKeys: String, CodingKey {
            case id = "wordid"
            case lang
            case lemma
        }
    }

    struct Sense: Decodable {
        let synset: String
        let wordId: Int
        let lang: String

        enum CodingKeys: String, CodingKey {
            case synset
            case wordId = "wordid"
            case lang
        }
    }

    struct Synset: Decodable {
        let synset: String
        let name: String
    }

    struct Synlink: Decodable {
        let synset1: String
        let synset2: String
        let link: String
    }

    struct SynlinkNetwork {
        let synlink: Synlink?
        let childlen: [String]
    }
}
