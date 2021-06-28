import Vapor

struct APIError: Error {
    let status: HTTPStatus
    let errorCode: ErrorCode
    let errorMessage: String?

    init(status: HTTPStatus, errorCode: ErrorCode = .unknown, errorMessage: String? = nil) {
        self.status = status
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}
