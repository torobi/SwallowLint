import Foundation
import ArgumentParser
import Yams
import SwiftParser
import SwiftSyntax

@main
struct SwallowLint: ParsableCommand {
    @Option(
        name: [.customLong("config")],
        help: "Config file path.",
        completion: .file(extensions: ["yml", "yaml"])
    )
    var configPath: String = ".swallowlint.yml"

    @Argument
    var path: String?

    private var config: Config?

    static let configuration: CommandConfiguration = .init(
        commandName: "swallow-lint",
        abstract: "simple swift linter.",
        shouldDisplay: true,
        helpNames: [.long, .short]
    )

    mutating func run() throws {
        config = try readConfig()
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