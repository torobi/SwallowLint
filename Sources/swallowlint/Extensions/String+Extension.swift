//
//  String+Extension.swift
//  swallowlint
//
//  Created by torobi on 2024/11/24.
//

import Foundation

extension String {
    var mark: String? {
        let regex = #/\/\/\s?MARK:\s*-?\s*(?<mark>.*)$/#

        if let mark = self.firstMatch(of: regex)?.output.mark {
            return String(mark)
        }
        
        return nil
    }
}
