import Foundation
import Yams

class ConfigCache {
    static let instance: ConfigCache = .init()
    private var configs = [String: Decodable]()

    func get<ConfigType: Decodable>(configType: ConfigType.Type, configPath: String, identifier: String) -> ConfigType? {
        if configs[identifier] == nil {
            configs[identifier] = try? readRuleConfig(configType: configType, configPath: configPath)
        }
        return configs[identifier] as? ConfigType
    }
    
    private func readRuleConfig<ConfigType: Decodable>(configType: ConfigType.Type, configPath: String) throws -> ConfigType? {
        guard FileManager.default.fileExists(atPath: configPath) else { return nil }
        let url = URL(fileURLWithPath: configPath)
        let decoder = YAMLDecoder()

        let data = try Data(contentsOf: url)
        return try decoder.decode(configType, from: data)
    }
}

protocol Rule {
    associatedtype Config: Decodable = EmptyRuleConfig
    associatedtype Visitor: ViolationsSyntaxVisitor<Config>
    var description: RuleDescription { get }
    var configType: Config.Type { get }

    func makeVisitor(configPath: String, file: SwallowLintFileProtocol) -> Visitor
}

extension Rule {
    var configType: Config.Type { Config.self }
    func makeVisitor(configPath: String, file: SwallowLintFileProtocol) -> Visitor {
        let config = ConfigCache.instance.get(configType: configType, configPath: configPath, identifier: description.identifier)
        return Visitor.init(config: config, ruleDescription: description, file: file)
    }

    func makeVisitor(config: Config, file: SwallowLintFileProtocol) -> Visitor {
        return Visitor.init(config: config, ruleDescription: description, file: file)
    }
}

private extension Rule {
    func readRuleConfig(configPath: String) throws -> Config? {
        guard FileManager.default.fileExists(atPath: configPath) else { return nil }
        let url = URL(fileURLWithPath: configPath)
        let decoder = YAMLDecoder()

        let data = try Data(contentsOf: url)
        return try decoder.decode(configType, from: data)
    }
}
