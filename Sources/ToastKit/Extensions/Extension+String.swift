//
//  Extension+String.swift
//  ToastKit
//
//  Created by Javier Gómez Ochoa on 30/04/2026.
//

import SwiftUI

extension String {
    var toMarkdown: AttributedString {
        do {
            return try AttributedString(markdown: self)
        } catch {
            print("Error parsing Markdown for string \(self): \(error)")
            return AttributedString(self)
        }
    }
}
