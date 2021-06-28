final class BotSessionData: Encodable {

    var favorabilityRating: Int
    var shouldLeave: Bool {
        favorabilityRating <= 0
    }

    init(favorabilityRating: Int) {
        self.favorabilityRating = favorabilityRating
    }
}

extension BotSessionData {
    static var `default`: BotSessionData {
        return .init(favorabilityRating: 10)
    }
}
