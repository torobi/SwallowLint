import Foundation
import SwiftParser
import SwiftSyntax
import SourceKittenFramework

final class SwallowLintFile: SwallowLintFileProtocol {
    let file: File
    let syntaxTree: SourceFileSyntax
    let locationConverter: SourceLocationConverter

    convenience init?(url: URL) {
        self.init(path: url.path())
    }

    convenience init?(path: String) {
        guard let file = File(path: path) else { return nil }
        self.init(file: file)
    }

    init(file: File) {
        self.file = file
        syntaxTree = Parser.parse(source: file.contents)
        locationConverter = SourceLocationConverter(fileName: file.path ?? "<nopath>", tree: syntaxTree)
    }
}
