//
//  UtilityExtensions.swift
//  disassembler
//
//  Created by Saurav Mitra on 12/08/2024.
//

import Foundation

typealias Matrix<Value> = [[Value]]

typealias MatrixIndex = (row: Int, col: Int)

extension Array where Element: MutableCollection, Element.Index == Int {
  subscript(_ row: Int, _ col: Int) -> Element.Element {
    get {
      self[row][col]
    }

    set {
      self[row][col] = newValue
    }
  }

  subscript(_ index: MatrixIndex) -> Element.Element {
    get {
      self[index.row][index.col]
    }

    set {
      self[index.row][index.col] = newValue
    }
  }
}
