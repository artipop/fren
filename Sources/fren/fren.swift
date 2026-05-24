import ArgumentParser
import Foundation

@main
struct fren: ParsableCommand {
    static let configuration = CommandConfiguration(
        subcommands: [hello.self, run.self]
    )
}

extension fren {
    struct hello: ParsableCommand {
        @Argument(help: "fren's name")
        var name: String

        func run() throws {
            print("Hello fren \(name)!")
        }
    }
}

extension fren {
    struct run: ParsableCommand {
        @Argument(help: "js file path")
        var path: String

        func run() throws {
            let base = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
            let url = URL(fileURLWithPath: path, relativeTo: base)
            let contents = try String(contentsOf: url, encoding: .utf8)
            print(contents, terminator: "")
        }
    }
}
