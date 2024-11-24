//
//  PropertyOrderRuleConfig.swift
//  swallowlint
//
//  Created by torobi on 2024/11/17.
//

import Foundation

// MARK - Config
extension PropertyOrderRuleConfig.RootConfig {
    struct Config: Codable {
        let separator_marks: [String]?
    }
}

struct PropertyOrderRuleConfig: Codable {
    struct RootConfig: Codable {
        let property_order: Config?
    }
    let rule_configs: RootConfig?
}
