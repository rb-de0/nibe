import Vapor

final class WebSocketResponseEndoder {

    func encode(response: WebSocketResponse) throws -> String {
        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        guard let text = String(data: data, encoding: .utf8) else {
            throw EncodeError.invalidResponseData
        }
        return text
    }
}

extension WebSocketResponseEndoder {
    enum EncodeError: Error {
        case invalidResponseData
    }
}
