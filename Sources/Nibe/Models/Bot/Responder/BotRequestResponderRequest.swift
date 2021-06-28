import Vapor

final class BotRequestResponderRequest {
    let botRequest: BotRequest
    let data: Data

    init(botRequest: BotRequest, data: Data) {
        self.botRequest = botRequest
        self.data = data
    }
}

extension BotRequestResponderRequest {
    final class Data {
        var session: Session

        init(session: Session) {
            self.session = session
        }
    }
}
