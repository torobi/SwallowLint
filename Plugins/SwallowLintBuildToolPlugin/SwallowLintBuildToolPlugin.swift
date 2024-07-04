import PackagePlugin

@main
struct SwallowLintBuildToolPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        createBuildCommands(
            packageDirectory: context.package.directory,
            workingDirectory: context.pluginWorkDirectory,
            tool: try context.tool(named: "swallowlint")
        )
    }

    private func createBuildCommands(
        packageDirectory: Path,
        workingDirectory: Path,
        tool: PluginContext.Tool
    ) -> [Command] {
        let configuration = packageDirectory.firstConfigurationFileInParentDirectories()

        var arguments = [
            packageDirectory.string
        ]

        if let configuration {
            arguments += [
                "--config", configuration.string
            ]
        }

        return [
            .buildCommand(
                displayName: "SwallowLintBuildToolPlugin",
                executable: tool.path,
                arguments: arguments
            )
        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwallowLintBuildToolPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        return createBuildCommands(
            packageDirectory: context.xcodeProject.directory,
            workingDirectory: context.pluginWorkDirectory,
            tool: try context.tool(named: "swallowlint")
        )
    }
}
#endif
