import Vapor

final class EventLoopFutureTaskQueue<T> {

    typealias FutureGenerator = () -> EventLoopFuture<T>

    private struct Task {
        let futureGenerator: FutureGenerator
        let promise: EventLoopPromise<T>
    }

    private let eventLoop: EventLoop
    private let limit: Int
    private var taskQueue: [Task] = []
    private var currentTask: Task?

    init(eventLoop: EventLoop, limit: Int) {
        self.eventLoop = eventLoop
        self.limit = limit
    }

    func enqueue(generator: @escaping FutureGenerator) -> EventLoopFuture<T> {
        return eventLoop.flatSubmit { [weak self, eventLoop] in
            guard let self = self else {
                return eventLoop.makeFailedFuture(Error.deallocated)
            }
            guard self.taskQueue.count < self.limit else {
                return eventLoop.makeFailedFuture(Error.capacityOver)
            }
            let promise = eventLoop.makePromise(of: T.self)
            let task = Task(futureGenerator: generator, promise: promise)
            self.taskQueue.append(task)
            self.dequeue()
            return promise.futureResult
        }
    }

    private func dequeue() {
        if taskQueue.isEmpty || currentTask != nil { return }
        let task = taskQueue.removeFirst()
        let future = task.futureGenerator()
        currentTask = task
        future.whenComplete { [weak self] result in
            self?.eventLoop.execute { [weak self] in
                self?.currentTask?.promise.completeWith(result)
                self?.currentTask = nil
                self?.dequeue()
            }
        }
    }

    deinit {
        currentTask?.promise.fail(Error.deallocated)
        taskQueue.forEach {
            $0.promise.fail(Error.deallocated)
        }
    }
}

extension EventLoopFutureTaskQueue {
    enum Error: Swift.Error {
        case capacityOver
        case deallocated
    }
}
