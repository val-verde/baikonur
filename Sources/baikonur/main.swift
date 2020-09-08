import ArgumentParser
import Dispatch
import Vapor

internal typealias Option = ArgumentParser.Option

internal struct ServerSessionState: ParsableCommand {
    static private var _serverPort = 0
    static private var serialQueue = DispatchQueue(label: "ServerSessionState.serialQueue")
    static fileprivate var serverPort: Int {
        get {
            return self.serialQueue.sync { self._serverPort }
        }

        set {
            self.serialQueue.async { self._serverPort = newValue }
        }
    }

    @Option(name: .shortAndLong, help: "Enter port number")
    internal var port: Int?

    mutating func run() throws {
        guard let _port = port else {
            preconditionFailure("Got nil for port.")
        }

        ServerSessionState.serverPort = _port
    }    
}

public func configure(_ app: Application) throws {
    precondition((ServerSessionState.serverPort > 0) &&
                 (ServerSessionState.serverPort <= 9999),
                 "Expected valid server port 1-9999, got \(ServerSessionState.serverPort).")

    app.http.server.configuration.port = ServerSessionState.serverPort
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

ServerSessionState.main()
try configure(app)
try app.run()

extension Environment {
    static var staging: Environment {
        .custom(name: "staging")
    }
}
