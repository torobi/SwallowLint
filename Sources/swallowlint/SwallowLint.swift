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

    static let configuration: CommandConfiguration = .init(
        commandName: "swallow-lint",
        abstract: "simple swift linter.",
        shouldDisplay: true,
        helpNames: [.long, .short]
    )

    func run() throws {
        let config = try readConfig()

        let fileManager: FileManager = .default
        let lintTargetPath = self.path ?? fileManager.currentDirectoryPath
        let url = URL(filePath: lintTargetPath)

        let excludedPaths = excludedPathsConvertToAbsolutePaths(excludedPaths: config.excluded ?? [])

        let targetFiles: [SwallowLintFile]
        if fileManager.isDirectory(url) {
            if excludedPaths.contains(url.path()) {
                targetFiles = []
            } else {
                targetFiles = try getTargetFiles(directory: url, excluded: excludedPaths)
            }
        } else {
            if let file = getTargetFile(file: url, excluded: excludedPaths) {
                targetFiles = [file]
            } else {
                targetFiles = []
            }
        }

        let reporter: Reporter.Type = XcodeReporter.self

        targetFiles.forEach { file in
            let commandVisitor = CommandVisitor(locationConverter: file.locationConverter)
            commandVisitor.walk(file.syntaxTree)
            let thisFileDisableRuleIdentifiers = Set(commandVisitor.thisCommands.flatMap { $0.ruleIdentifiers })
            let nextDisableRulesLines = commandVisitor.nextDisableRulesLines

            for rule in rules {
                if thisFileDisableRuleIdentifiers.contains(rule.description.identifier) { continue }

                let visitor = rule.makeVisitor(file: file)
                visitor.walk()
                let violations: [StyleViolation]

                if let disableLines = nextDisableRulesLines[rule.description.identifier]
                {
                    violations = visitor.violations.filter { violation in
                        guard let violationLine = violation.location.line else { return false }
                        return disableLines.contains(violationLine)
                    }
                } else {
                    violations = visitor.violations
                }

                if !violations.isEmpty {
                    print(reporter.generateReport(violations))
                }
            }
        }
    }
}

// MARK: - getTargetFiles
private extension SwallowLint {
    func excludedPathsConvertToAbsolutePaths(excludedPaths: [String]) -> [String] {
        return excludedPaths.map { URL(filePath: $0).absoluteURL.path() }
    }

    func getTargetFiles(directory url: URL, excluded: [String]) throws -> [SwallowLintFile] {
        let fileManager: FileManager = .default
        let contents = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil
        )

        var files: [SwallowLintFile] = []

        for content in contents {
            if fileManager.isDirectory(content) {
                if excluded.contains(content.path()) { continue }
                files += try getTargetFiles(directory: content, excluded: excluded)
            } else if content.pathExtension == "swift" {
                if let file = getTargetFile(file: content, excluded: excluded) {
                    files += [file]
                }
            }
        }

        return files
    }

    func getTargetFile(file url: URL, excluded: [String]) -> SwallowLintFile? {
        if excluded.contains(url.absoluteURL.path()) { return nil }
        return SwallowLintFile(url: url)
    }
}

// MARK: - Lint
private extension SwallowLint {
    func lint(files: [SwallowLintFile]) {

    }

    func lint(file: SwallowLintFile) {

    }
}

// MARK: - Config
private extension SwallowLint {
    func readConfig() throws -> Config {
        guard FileManager.default.fileExists(atPath: configPath) else {
            return Config()
        }
        let url = URL(fileURLWithPath: configPath)
        let decoder = YAMLDecoder()

        let data = try Data(contentsOf: url)
        return try decoder.decode(Config.self, from: data)
    }
}