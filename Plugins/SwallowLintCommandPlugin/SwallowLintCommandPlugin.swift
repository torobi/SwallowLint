import Foundation
import PackagePlugin

@main
struct SwallowLintCommandPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        try performCommand(
            packageDirectory: context.package.directory,
            tool: try context.tool(named: "swallowlint"),
            arguments: arguments
        )
    }

    private func performCommand(
        packageDirectory: Path,
        tool: PluginContext.Tool,
        arguments: [String]
    ) throws {
        var argumentExtractor = ArgumentExtractor(arguments)
        let config = argumentExtractor.extractOption(named: "config").first
        ?? packageDirectory.firstConfigurationFileInParentDirectories()?.string ?? ""
        let _ = argumentExtractor.extractOption(named: "target")
        let path = argumentExtractor.remainingArguments.first ?? packageDirectory.string

        let process = Process()
        process.launchPath = tool.path.string
        process.arguments = [
            path,
            "--config",
            config,
        ]

        try process.run()
        process.waitUntilExit()
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwallowLintCommandPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodeProjectPlugin.XcodePluginContext, arguments: [String]) throws {
        return try performCommand(
            packageDirectory: context.xcodeProject.directory,
            tool: try context.tool(named: "swallowlint"),
            arguments: arguments
        )
    }
}
#endif
