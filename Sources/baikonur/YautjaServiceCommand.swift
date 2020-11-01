import Foundation
import Vapor

internal enum YautjaServiceCommand: String {
    case createDirectory = "create-directory"
    case delete = "delete"
    case readDirectory = "read-directory"
    case readFile = "read-file"
    case rename = "rename"
    case stat = "stat"
    case writeFile = "write-file"

    internal func perform(config: YautjaServiceConfiguration,
                          arguments: YautjaServiceArguments) -> String {
        guard let uri = arguments.uri else {
            return ""
        }

        let url = URL(fileURLWithPath: "\(config.fsRoot)/\(uri)")
        let isDirectory = (try? url.resourceValues(forKeys: [ .isDirectoryKey ]))?.isDirectory ?? false

        switch self {
        case .createDirectory:
            guard !FileManager.default.fileExists(atPath: url.path) else {
                return ""
            }

            let result = url.path.withCString { path in
                mkdir(path, S_IRWXU | S_IRWXG | S_IRWXO)
            }

            precondition(result == 0, "Failed to create \(url), error: \(String(cString: strerror(errno))).")
            return "create-directory \(url)"

        case .delete:
            let result = url.path.withCString { path -> Int32 in
                isDirectory ? rmdir(path) :
                              unlink(path)
            }

            precondition(result == 0, "Failed to delete \(url), error: \(String(cString: strerror(errno))).")
            return "delete \(uri)"

        case .readDirectory:
            guard isDirectory,
                  let contents = url.path.withCString({ path -> String? in
                var contents = ""

                guard let directory = opendir(path) else {
                    return contents
                }

                while let entry = readdir(directory) {
                    contents += "\(String(cString: &entry.pointee.d_name.0))\n"
                }

                return contents
            }) else {
                preconditionFailure("Failed to read directory at \(url), error: \(String(cString: strerror(errno))).")
            }

            return "read-directory \(url)\n\(contents)"

        case .readFile:
            guard !isDirectory,
                  let contents = try? String(contentsOf: url) else {
                return ""
            }

            return "read-file \(url)\n\(contents)"

        case .rename:
            return "rename \(url)"

        case .stat:
            return "stat \(url)"

        case .writeFile:
            return "write-file \(url)"
        }

    }
}

internal struct YautjaServiceArguments: Content {
    internal var uri: String?
}

internal struct YautjaServiceConfiguration {
    internal var fsRoot = String(cString: getenv("HOME"))
}