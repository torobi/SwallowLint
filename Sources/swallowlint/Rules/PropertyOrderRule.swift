import SwiftSyntax

struct PropertyOrderRule: Rule {
    typealias Visitor = PropertyOrderRuleVisitor

    let description = RuleDescription(
        identifier: "property_order",
        name: "Property Order Rule",
        description: "Need to order properties according to modifiers."
    )
}

final class PropertyOrderRuleVisitor: ViolationsSyntaxVisitor {
    override func visitPost(_ node: MemberBlockSyntax) {
        allCheck(node)
    }

    /// 各プロパティの前後のみをチェック
    func quickCheck(_ node: MemberBlockSyntax) {
        var properties = getProperties(rootNode: node)

        if properties.isEmpty { return }

        var previous = properties.removeFirst()

        for property in properties {
            let (isCorrectOrder, reason) = checkCorrectOrder(aboveProperty: previous, belowProperty: property)
            if !isCorrectOrder {
                addViolation(node: property.node, reason: reason)
            }

            previous = property
        }
    }

    /// 各プロパティ毎にそれより下に定義されている全プロパティをチェック
    func allCheck(_ node: MemberBlockSyntax) {
        let properties = getProperties(rootNode: node)

        if properties.isEmpty { return }

        for abovePropertyIndex in 0..<properties.count {
            let aboveProperty = properties[abovePropertyIndex]
            for belowPropertyIndex in abovePropertyIndex..<properties.count {
                let belowProperty = properties[belowPropertyIndex]
                let (isCorrectOrder, reason) = checkCorrectOrder(aboveProperty: aboveProperty, belowProperty: belowProperty)
                if !isCorrectOrder {
                    addViolation(node: belowProperty.node, reason: reason)
                }
            }
        }
    }
}

private extension PropertyOrderRuleVisitor {
    func getProperties(rootNode: MemberBlockSyntax) -> [Property] {
        return rootNode.members.compactMap {
            if let decl = $0.decl.as(VariableDeclSyntax.self) {
                return Property(decl: decl)
            } else {
                return nil
            }
        }
    }

    func checkCorrectOrder(aboveProperty: Property, belowProperty: Property) -> (Bool, String?) {
        var belowModifierIndex = 0
        aboveLoop: for aboveModifier in aboveProperty.modifiers {
            for belowModifier in belowProperty.modifiers[belowModifierIndex...] {
                belowModifierIndex += 1

                if aboveModifier > belowModifier {
                    let aboveLine = location(node: aboveProperty.node).line ?? 0
                    let reason = "Properties declared with \"\(belowModifier)\" need to be defined above \"\(aboveModifier)\"(line: \(aboveLine))"
                    return (false, reason)
                } else if aboveModifier == belowModifier {
                    continue aboveLoop
                } else {
                    break aboveLoop
                }
            }
        }

        return (true, nil)
    }

    struct Property {
        let node: VariableDeclSyntax
        let modifiers: [Modifier]

        init(decl: VariableDeclSyntax) {
            node = decl
            modifiers = Property.extractModifiers(decl: decl)
        }

        private static func extractModifiers(decl: VariableDeclSyntax) -> [Modifier] {
            var modifiers = decl.modifiers.compactMap {
                Modifier(rawValue: $0.name.text)
            }

            // internalが省略されている場合は追加
            let accessLevels: Set<Modifier> = [.open, .public, .package, .internal, .fileprivate, .private]
            if Set(modifiers).intersection(accessLevels).count == 0 {
                modifiers.append(.internal)
            }

            // @IBOutletがある場合追加
            for rawAttribute in decl.attributes {
                guard let attribute = rawAttribute.as(AttributeSyntax.self) else { continue }
                if attribute.attributeName.description == "IBOutlet" {
                    modifiers.append(.IBOutlet)
                    break
                }
            }

            // let/var を追加
            if let letOrVer = Modifier(rawValue: decl.bindingSpecifier.text) {
                modifiers.append(letOrVer)
            }

            return modifiers.sorted { $0 < $1 }
        }
    }
}

private extension PropertyOrderRuleVisitor {
    enum Modifier: String, CaseIterable, Comparable {
        case `static`

        case `open`
        case `public`
        case `package`
        case `internal`
        case `fileprivate`
        case `private`

        case `let`
        case `var`

        case IBOutlet
        case weak
        case lazy

        static func < (lhs: Modifier, rhs: Modifier) -> Bool {
            return lhs.order < rhs.order
        }

        var order: Int {
            return Modifier.allCases.firstIndex(of: self) ?? 0
        }
    }
}