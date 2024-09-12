//
//  SwallowLintFileProtocol.swift
//  
//
//  Created by torobi on 2024/09/12.
//

import Foundation
import SwiftSyntax

protocol SwallowLintFileProtocol {
    var syntaxTree: SourceFileSyntax { get }
    var locationConverter: SourceLocationConverter { get }
}
