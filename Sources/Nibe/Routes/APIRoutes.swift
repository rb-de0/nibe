import Vapor

final class APIRoutes: RouteCollection {

    func boot(routes: RoutesBuilder) throws {

        let api = routes
            .grouped("api")
            .grouped("v1")

        let secure = api.grouped(Session.guardMiddleware())

        // sessions
        do {
            let controller = SessionController()
            api.get("csrf", use: controller.getCSRFToken)
        }

        // tickets
        do {
            let controller = TicketController()
            secure.post("tickets", use: controller.createTicket)
        }
    }
}
