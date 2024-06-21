import Foundation
import ArgumentParser
import Yams

@main
struct SwallowLint: ParsableCommand {
    @Option(
        name: [.customLong("config")],
        help: "Config file path.",
        completion: .file(extensions: ["yml", "yaml"])
    )
    var configPath: String = ".swallowlint.yml"

    private var config: Config?

    static let configuration: CommandConfiguration = .init(
        commandName: "swallow-lint",
        abstract: "simple swift linter.",
        shouldDisplay: true,
        helpNames: [.long, .short]
    )

    mutating func run() throws {
        config = try readConfig()
        let report = XcodeReporter.generateReport([
            StyleViolation(
                ruleIdentifier: "ruleA.id",
                ruleDescription: "this is rule A description.",
                ruleName: "ruleA",
                severity: .error,
                location: Location(file: "hoge.swift", line: 10, character: 20),
                reason: "this is rule A reason."
            )
        ])
        print(report)
    }
}

// MARK: - Config
private extension SwallowLint {
    mutating func readConfig() throws -> Config {
        guard FileManager.default.fileExists(atPath: configPath) else {
            return Config()
        }
        let url = URL(fileURLWithPath: configPath)
        let decoder = YAMLDecoder()

        let data = try Data(contentsOf: url)
        return try decoder.decode(Config.self, from: data)
    }
}