import Vapor

final class JSONLoader {

    private let directory: String

    init(directory: String) {
        self.directory = directory
    }

    func load<T: Decodable>(for app: Application, name: String) throws -> T {
        let configDirectory = app.directory.workingDirectory.finished(with: "/").appending(directory)
        let targetDirectories = ["", "secrets", app.environment.name]
        var configFileData: Data?
        for target in targetDirectories {
            var configFilePath = configDirectory.finished(with: "/")
                .appending(target).finished(with: "/")
                .appending(name)
            if !configFilePath.hasSuffix(".json") {
                configFilePath = configFilePath.appending(".json")
            }
            guard let data = FileManager.default.contents(atPath: configFilePath) else {
                continue
            }
            configFileData = data
        }
        app.logger.debug("Loading Config at \(name)")
        guard let data = configFileData else {
            fatalError("config file not found")
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
