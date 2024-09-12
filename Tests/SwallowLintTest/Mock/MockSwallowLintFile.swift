//
//  MockSwallowLintFile.swift
//  
//
//  Created by torobi on 2024/09/12.
//

import Foundation
@testable import swallowlint
import SwiftSyntax
import SwiftParser

struct MockSwallowLintFile: SwallowLintFileProtocol {
    var syntaxTree: SourceFileSyntax
    let locationConverter: SourceLocationConverter
    
    init(source: String) {
        self.syntaxTree = Parser.parse(source: source)
        self.locationConverter = .init(fileName: "", tree: syntaxTree)
    }
}
