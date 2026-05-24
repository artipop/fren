import ArgumentParser

@main
struct fren: ParsableCommand {
    @Argument(help: "The person to greet.")
    public var name: String

    public func run() throws {
        print("Hello fren, \(name)!")
    }
}
