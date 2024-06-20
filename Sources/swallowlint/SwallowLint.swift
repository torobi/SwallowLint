import ArgumentParser

@main
struct SwallowLint: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "swallow-lint",
        abstract: "simple swift linter.",
        shouldDisplay: true,
        helpNames: [.long, .short]
    )

    mutating func run() throws {
        print("run")
    }
}
