import Vapor

struct APIErrorResponse: Content {
    let errorCode: String
    let errorMessage: String
}

extension ErrorMiddleware {
    static func forAPI() -> ErrorMiddleware {
        return .init { request, error in
            let status: HTTPStatus
            let errorCode: String
            let errorMessage: String
            let headers: HTTPHeaders
            switch error {
            case let abort as AbortError:
                status = abort.status
                errorCode = ErrorCode.unknown.rawValue
                errorMessage = abort.reason
                headers = abort.headers
            case let apiError as APIError:
                status = apiError.status
                errorCode = apiError.errorCode.rawValue
                errorMessage = apiError.errorMessage ?? "Something went wrong."
                headers = [:]
            default:
                status = .internalServerError
                errorCode = ErrorCode.unknown.rawValue
                errorMessage = "Something went wrong."
                headers = [:]
            }
            request.logger.report(error: error)
            let response = Response(status: status, headers: headers)
            do {
                let errorResponse = APIErrorResponse(errorCode: errorCode, errorMessage: errorMessage)
                response.body = try .init(data: JSONEncoder().encode(errorResponse))
                response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
            } catch {
                response.body = .init(string: "Oops: \(error)")
                response.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
            }
            return response
        }
    }
}
