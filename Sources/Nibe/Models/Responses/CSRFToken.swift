import Vapor

struct CSRFToken: Content {
    let token: String
}
