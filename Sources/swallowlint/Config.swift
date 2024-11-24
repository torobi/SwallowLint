struct Config: Decodable {
    var disabled_rules: [String]?
    var excluded: [String]?

    // var rule_configs: [String: Any]? // decode by each Rule
}

struct EmptyRuleConfig: Decodable {}
