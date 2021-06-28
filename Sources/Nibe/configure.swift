import Vapor
import MongoKitten
import MongoClient
import VaporSecurityHeaders

public func configure(_ app: Application) throws {

    // logger
    app.logger.logLevel = app.environment == .development ? .debug : .info

    // set working directory
    app.directory = DirectoryConfiguration(workingDirectory: .workingDirectory)

    // register configs
    let configLoader = JSONLoader(directory: "Config")
    app.configuration = try configLoader.load(for: app, name: "config")

    // set public directory
    app.directory.publicDirectory = app.directory.workingDirectory
        .finished(with: "/")
        .appending(app.configuration.paths.public)

    // register bot dictionaries
    app.botDictionaries = try BotDictionaries.load(for: app)

    // register services
    app.dateProvider = DefaultDateProvider()
    app.connectionTokenGenerator = DefaultConnectionTokenGenerator()
    app.webSocketClientPool = WebSocketClientPool(maxClientConnnections: app.configuration.server.maxClientConnections)
    let wordnetPath = app.directory.workingDirectory.finished(with: "/").appending(app.configuration.paths.wordnetFile)
    let similarWordsResolver = WordNetSimilarWordsResolver(application: app, databasePath: wordnetPath)
    app.conversationMatchResolver = DefaultConversationMatchResolver(
        threadPool: app.threadPool,
        similarWordsResolver: similarWordsResolver,
        conversationDictionary: app.botDictionaries.conversationDictionary
    )

    // databases
    do {
        let mongoURI = ProcessInfo.processInfo.environment["MongoURI"] ?? app.configuration.server.mongoURI
        try app.initializeMongoDB(connectionString: mongoURI)
    }

    // create indexes
    do {
        let sessions = app.mongoDB[Session.collectionName]
        var ttlIndex = CreateIndexes.Index(named: "ttl", keys: [
            "updatedAt": 1
        ])
        ttlIndex.expireAfterSeconds = 3600
        createIndex(collection: sessions, index: ttlIndex)
    }
    do {
        let tickets = app.mongoDB[Ticket.collectionName]
        var ttlIndex = CreateIndexes.Index(named: "ttl", keys: [
            "createdAt": 1
        ])
        ttlIndex.expireAfterSeconds = 60
        var uniqueIndex = CreateIndexes.Index(named: "unique", keys: [
            "token": 1
        ])
        uniqueIndex.unique = true
        createIndex(collection: tickets, index: ttlIndex)
        createIndex(collection: tickets, index: uniqueIndex)
    }

    // bot request middlewares
    var botRequestMiddlewares = BotRequestMiddlewares()
    botRequestMiddlewares.add(BotBadwordMiddleware())
    botRequestMiddlewares.add(BotConversationMiddleware(conversationMatchResolver: app.conversationMatchResolver))
    botRequestMiddlewares.add(BotFallbackMiddleware(conversationMatchResolver: app.conversationMatchResolver))
    app.botRequestMiddlewares = botRequestMiddlewares

    // session
    if app.environment == .production {
        app.sessions.configuration = SessionsConfiguration(cookieName: "vapor-session") { sessionID in
            return HTTPCookies.Value(
                string: sessionID.string,
                expires: nil,
                maxAge: nil,
                domain: nil,
                path: "/",
                isSecure: app.configuration.server.secureOnly,
                isHTTPOnly: true,
                sameSite: .lax
            )
        }
    } else {
        app.sessions.configuration = SessionsConfiguration(cookieName: "vapor-session") { sessionID in
            return HTTPCookies.Value(
                string: sessionID.string,
                expires: nil,
                maxAge: nil,
                domain: nil,
                path: "/",
                isSecure: false,
                isHTTPOnly: true,
                sameSite: .lax
            )
        }
    }
    app.sessions.use { _ in MongoSessionDriver() }

    // middleware
    let securityHeaders = SecurityHeadersFactory().with(contentSecurityPolicy: .init(value: "")).build()
    app.middleware.use(securityHeaders)
    if app.environment == .production {
        let corsConfiguration = CORSMiddleware.Configuration(
            allowedOrigin: .any([app.configuration.server.origin]),
            allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
            allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith],
            allowCredentials: true,
            cacheExpiration: nil,
            exposedHeaders: nil
        )
        app.middleware.use(CORSMiddleware(configuration: corsConfiguration))
    } else {
        let corsConfiguration = CORSMiddleware.Configuration(
            allowedOrigin: .originBased,
            allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
            allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith],
            allowCredentials: true,
            cacheExpiration: nil,
            exposedHeaders: nil
        )
        app.middleware.use(CORSMiddleware(configuration: corsConfiguration))
    }
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    let error = ErrorMiddleware.forAPI()
    app.middleware.use(error)

    // server config
    app.http.server.configuration.hostname = "0.0.0.0"

    // routing
    try routes(app)
}

private func createIndex(collection: MongoCollection, index: CreateIndexes.Index) {
    do {
        try collection.createIndexes([
            index
        ]).wait()
    } catch {
        guard let mongoError = error as? MongoGenericErrorReply else {
            fatalError(error.localizedDescription)
        }
        guard mongoError.codeName == "IndexOptionsConflict" else {
            fatalError(error.localizedDescription)
        }
    }
}

private extension String {
    static var workingDirectory: String {
        return #file.components(separatedBy: "/Sources/Nibe").first ?? ""
    }
}
