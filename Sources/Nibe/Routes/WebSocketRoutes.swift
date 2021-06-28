import Vapor

final class WebSocketRoutes: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let controller = WebSocketController()
        routes.webSocket("websocket", shouldUpgrade: controller.shouldUpgrade, onUpgrade: controller.onUpgrade)
    }
}
