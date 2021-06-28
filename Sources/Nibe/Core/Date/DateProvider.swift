import Vapor

protocol DateProvider {
    func date() -> Date
    func calender() -> Calendar
}

final class DefaultDateProvider: DateProvider {
    func date() -> Date {
        return Date()
    }

    func calender() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "JST")!
        return calendar
    }
}

private struct DateProviderKey: StorageKey {
    typealias Value = DateProvider
}

extension Application {
    var dateProvider: DateProvider {
        get {
            return storage[DateProviderKey.self]!
        }
        set {
            storage[DateProviderKey.self] = newValue
        }
    }
}
