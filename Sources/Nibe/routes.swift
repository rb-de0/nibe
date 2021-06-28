import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: WebSocketRoutes())
    let root = app
        .grouped(app.sessions.middleware)
        .grouped(UserSessionAuthenticator())
    try root.register(collection: APIRoutes())
    registerFallback(routes: root)
}

private func registerFallback(routes: RoutesBuilder) {
    routes.get("") { request -> Response in
        let path = request.application.directory.publicDirectory.appending("/index.html")
        return request.fileio.streamFile(at: path)
    }
}
