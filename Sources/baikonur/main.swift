import ArgumentParser
import Dispatch
import Vapor

internal typealias Option = ArgumentParser.Option

internal struct ServerSessionState: ParsableCommand {
    static private var _serverHostName = "localhost"
    static private var _serverPort = 4000
    static private var _yautjaConfig = YautjaServiceConfiguration()
    static private var serialQueue = DispatchQueue(label: "ServerSessionState.serialQueue")

    static fileprivate var serverHostName: String {
        get {
            return self.serialQueue.sync { self._serverHostName }
        }

        set {
            self.serialQueue.async { self._serverHostName = newValue }
        }
    }

    static fileprivate var serverPort: Int {
        get {
            return self.serialQueue.sync { self._serverPort }
        }

        set {
            self.serialQueue.async { self._serverPort = newValue }
        }
    }

    static fileprivate var yautjaConfig: YautjaServiceConfiguration {
        get {
            return self.serialQueue.sync { self._yautjaConfig }
        }

        set {
            self.serialQueue.async { self._yautjaConfig = newValue }
        }
    }

    @Option(name: .shortAndLong, help: "Enter host name")
    internal var hostname: String?

    @Option(name: .shortAndLong, help: "Enter port number")
    internal var port: Int?

    @Option(name: .shortAndLong, help: "File system extension root")
    internal var fsRoot: String?

    mutating func run() throws {
        if let hostname = self.hostname {
            ServerSessionState.serverHostName = hostname
        }

        if let port = self.port {
            ServerSessionState.serverPort = port
        }

        if let fsRoot = self.fsRoot {
            ServerSessionState.yautjaConfig.fsRoot = fsRoot
        }
    }
}

public func configure(_ app: Application) throws {
    precondition((ServerSessionState.serverPort > 0) &&
                 (ServerSessionState.serverPort <= 9999),
                 "Expected valid server port 1-9999, got \(ServerSessionState.serverPort).")

    app.http.server.configuration.port = ServerSessionState.serverPort
    app.http.server.configuration.hostname = ServerSessionState.serverHostName
    try routes(app)
}

public func routes(_ app: Application) throws {
    app.get("yautja", ":command") { req -> String in
        guard let _command = req.parameters.get("command"),
              let command = YautjaServiceCommand(rawValue: _command),
              let serviceArguments = try? req.query.decode(YautjaServiceArguments.self) else {
            return ""
        }

        return command.perform(config: ServerSessionState.yautjaConfig,
                               arguments: serviceArguments)
    }
}

var env = Environment(name: "staging", arguments: ["vapor"])

try LoggingSystem.bootstrap(from: &env)

let app = Application(env)

defer { app.shutdown() }

let corsConfiguration = CORSMiddleware.Configuration(allowedOrigin: .all,
                                                     allowedMethods: [
                                                         .GET,
                                                         .POST,
                                                     ],
                                                     allowedHeaders: [
                                                         .accept,
                                                         .accessControlAllowOrigin,
                                                         .authorization,
                                                         .contentType,
                                                         .origin,
                                                         .userAgent,
                                                         .xRequestedWith,
                                                     ])
let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
var middleware = Middlewares()

middleware.use(corsMiddleware)
app.middleware = middleware

ServerSessionState.main()
try configure(app)
try app.run()

extension Environment {
    static var staging: Environment {
        .custom(name: "staging")
    }
}
