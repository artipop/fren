import ArgumentParser
import Foundation
import JavaScriptCore

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

            let context = JSContext()!
            context.exceptionHandler = { _, exception in
                if let error = exception?.toString() {
                    fputs("JS error: \(error)\n", stderr)
                }
            }
            // Bridge console.log to print
            let consolePrint: @convention(block) (JSValue) -> Void = { value in
                print(value.toString() ?? "")
            }
            context.objectForKeyedSubscript("console")
            let console = JSValue(newObjectIn: context)!
            console.setValue(consolePrint as AnyObject, forProperty: "log")
            context.setObject(console, forKeyedSubscript: "console" as NSString)

            let fs = JSValue(newObjectIn: context)!

            let readFileSync: @convention(block) (String) -> String = { p in
                let fileURL = URL(fileURLWithPath: p, relativeTo: base)
                return (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
            }
            fs.setValue(readFileSync as AnyObject, forProperty: "readFileSync")

            let writeFileSync: @convention(block) (String, String) -> Void = { p, data in
                let fileURL = URL(fileURLWithPath: p, relativeTo: base)
                try? data.write(to: fileURL, atomically: true, encoding: .utf8)
            }
            fs.setValue(writeFileSync as AnyObject, forProperty: "writeFileSync")

            let existsSync: @convention(block) (String) -> Bool = { p in
                let fileURL = URL(fileURLWithPath: p, relativeTo: base)
                return FileManager.default.fileExists(atPath: fileURL.path)
            }
            fs.setValue(existsSync as AnyObject, forProperty: "existsSync")

            let readdirSync: @convention(block) (String) -> [String] = { p in
                let fileURL = URL(fileURLWithPath: p, relativeTo: base)
                return (try? FileManager.default.contentsOfDirectory(atPath: fileURL.path)) ?? []
            }
            fs.setValue(readdirSync as AnyObject, forProperty: "readdirSync")

            context.globalObject.setValue(fs, forProperty: "fs")

            context.evaluateScript(contents)
        }
    }
}
