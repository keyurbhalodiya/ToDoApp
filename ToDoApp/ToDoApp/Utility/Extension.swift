//
//  Extension.swift
//  ToDoApp
//
//  Created by Keyur Bhalodiya on 2024/09/19.
//

import Foundation
import SwiftUI

extension Date {
  func dateAndTimeAsString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    return dateFormatter.string(from: self)
  }
}


extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
    let rgbValue = UInt32(hex, radix: 16)
    let r = Double((rgbValue! & 0xFF0000) >> 16) / 255
    let g = Double((rgbValue! & 0x00FF00) >> 8) / 255
    let b = Double(rgbValue! & 0x0000FF) / 255
    self.init(red: r, green: g, blue: b)
  }
}
