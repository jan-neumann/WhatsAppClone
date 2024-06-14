//
//  String+Extensions.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 14.06.24.
//

import Foundation

extension String {
    var isEmptyOrWhitespace: Bool { return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}
