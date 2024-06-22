import SwiftSyntax

class ViolationsSyntaxVisitor: SyntaxVisitor {
    private let file: SwallowLintFile
    private lazy var locationConverter = file.locationConverter
    private(set) var violationLocations: [(line: Int, column: Int)] = []

    init(file: SwallowLintFile) {
        self.file = file
        super.init(viewMode: .all)
    }

    func addLocation(node: Syntax) {
        let location = node.startLocation(converter: locationConverter)
        self.violationLocations.append((line: location.line, column: location.column))
    }
}