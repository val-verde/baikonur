import Vapor

/// Called before your application initializes.
public func configure(_ app: Application) throws {
    app.http.server.configuration.port = 8888
    try routes(app)
}

/// Register your application's routes here.
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
