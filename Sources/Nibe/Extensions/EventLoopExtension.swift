import Vapor
import NIO

extension EventLoopFuture {
    static func sequence<T>(initialFuture: EventLoopFuture<T>, generator: @escaping ((T) -> EventLoopFuture<T>?)) -> EventLoopFuture<T> {
        let promise = initialFuture.eventLoop.makePromise(of: T.self)
        func bind(future: EventLoopFuture<T>) {
            future.whenSuccess { value in
                if let next = generator(value) {
                    bind(future: next)
                } else {
                    promise.succeed(value)
                }
            }
            future.whenFailure { error in
                promise.fail(error)
            }
        }
        bind(future: initialFuture)
        return promise.futureResult
    }
}
