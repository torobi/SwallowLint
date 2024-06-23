import Foundation
import SwiftSyntax

/// The placement of a segment of Swift in a collection of source files.
struct Location: CustomStringConvertible, Comparable, Codable, Sendable {
    /// The file path on disk for this location.
    let file: String?
    /// The line offset in the file for this location. 1-indexed.
    let line: Int?
    /// The character offset in the file for this location. 1-indexed.
    let character: Int?

    /// A lossless printable description of this location.
    var description: String {
        // Xcode likes warnings and errors in the following format:
        // {full_path_to_file}{:line}{:character}: {error,warning}: {content}
        let fileString = file ?? "<nopath>"
        let lineString = ":\(line ?? 1)"
        let charString = ":\(character ?? 1)"
        return [fileString, lineString, charString].joined()
    }

    /// The file path for this location relative to the current working directory.
    var relativeFile: String? {
        return file?.replacingOccurrences(of: FileManager.default.currentDirectoryPath + "/", with: "")
    }

    /// Creates a `Location` by specifying its properties directly.
    ///
    /// - parameter file:      The file path on disk for this location.
    /// - parameter line:      The line offset in the file for this location. 1-indexed.
    /// - parameter character: The character offset in the file for this location. 1-indexed.
    init(file: String?, line: Int? = nil, character: Int? = nil) {
        self.file = file
        self.line = line
        self.character = character
    }

    init(sourceLocation: SourceLocation) {
        self.init(file: sourceLocation.file, line: sourceLocation.line, character: sourceLocation.column)
    }

    // MARK: Comparable

    static func < (lhs: Location, rhs: Location) -> Bool {
        if lhs.file != rhs.file {
            return lhs.file < rhs.file
        }
        if lhs.line != rhs.line {
            return lhs.line < rhs.line
        }
        return lhs.character < rhs.character
    }
}

private extension Optional where Wrapped: Comparable {
    static func < (lhs: Optional, rhs: Optional) -> Bool {
        switch (lhs, rhs) {
        case let (lhs?, rhs?):
            return lhs < rhs
        case (nil, _?):
            return true
        default:
            return false
        }
    }
}