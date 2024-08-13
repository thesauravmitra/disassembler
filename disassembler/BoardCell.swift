//
//  BoardCell.swift
//  disassembler
//
//  Created by Saurav Mitra on 12/08/2024.
//

import Foundation

extension Board {
  struct Cell: RawRepresentable {
    indirect enum Content: RawRepresentable {
      case simple(Color)
      case nested(outer: Color, inner: Cell)

      var rawValue: String {
        switch self {
        case .simple(let color): return color.rawValue
        case .nested(let outer, let inner): return "\(inner.rawValue)\(outer.rawValue)"
        }
      }

      init?(rawValue: String) {
        guard let lastCharacter = rawValue.last else { return nil }

        if rawValue.count > 1 {
          guard let outer = Color(rawValue: String(lastCharacter)), let inner = Cell(rawValue: String(rawValue.dropLast())) else {
            return nil
          }
          self = .nested(outer: outer, inner: inner)
        } else {
          guard let color = Color(rawValue: rawValue) else { return nil }
          self = .simple(color)
        }
      }
    }

    var content: Content
    let fixed: Bool

    var rawValue: String {
      "\(content.rawValue)\(fixed ? "*" : "")"
    }

    init?(rawValue: String) {
      var rawValue = rawValue
      if rawValue.last == "*" {
        fixed = true
        rawValue.removeLast()
      } else {
        fixed = false
      }

      guard let content = Content(rawValue: rawValue) else { return nil }
      self.content = content
    }

    var outerColor: Cell.Color {
      switch content {
      case .simple(let color): return color
      case .nested(let outerColor, _): return outerColor
      }
    }

    var innerCell: Cell {
      switch content {
      case .simple: return self
      case .nested(_, let innerCell): return innerCell
      }
    }
  }
}

extension Board.Cell {
  enum Color: String {
    case green = "G"
    case orange = "o"
    case gray = "g"
    case yellow = "y"
    case blue = "b"
  }
}
