import Vapor

final class WebSocketRequestDecoder {

    func decode(text: String) throws -> WebSocketRequest {
        guard let data = text.data(using: .utf8) else {
            throw DecodeError.invalidTextData
        }
        let decoder = JSONDecoder()
        return try decoder.decode(WebSocketRequest.self, from: data)
    }
}

extension WebSocketRequestDecoder {
    enum DecodeError: Error {
        case invalidTextData
    }
}
