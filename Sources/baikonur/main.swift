import Vapor

public func configure(_ app: Application) throws {
    app.http.server.configuration.port = 443
    try routes(app)
}

public func routes(_ app: Application) throws {
    app.get { req in
        return "Hello, world!"
    }
}

var env = Environment(name: "staging", arguments: ["vapor"])
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
try app.run()

extension Environment {
    static var staging: Environment {
        .custom(name: "staging")
    }
}
