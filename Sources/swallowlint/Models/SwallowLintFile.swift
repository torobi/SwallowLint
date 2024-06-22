import SwiftParser
import SwiftSyntax
import SourceKittenFramework

final class SwallowLintFile {
    let file: File
    let syntaxTree: SourceFileSyntax
    let locationConverter: SourceLocationConverter

    init(file: File) {
        self.file = file
        syntaxTree = Parser.parse(source: file.contents)
        locationConverter = SourceLocationConverter(fileName: file.path ?? "<nopath>", tree: syntaxTree)
    }

    convenience init?(path: String) {
        guard let file = File(path: path) else { return nil }
        self.init(file: file)
    }
}