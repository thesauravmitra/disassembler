//
//  Board.swift
//  disassembler
//
//  Created by Saurav Mitra on 12/08/2024.
//

import Foundation

struct Board {
  private(set) var cells: Matrix<Cell?>

  private(set) var width: Int
  private(set) var height: Int

  private(set) var firstCellIndex: MatrixIndex?
  private(set) var numberOfCells: Int

  enum BoardError: Error {
    case badType, badMove
  }

  init(_ string: String) throws {
    cells = []

    var linearFirstIndex = 0
    var numberOfCells = 0

    for rowString in string.split(separator: ",") {
      let row: [Cell?] = try rowString
        .split(separator: ".")
        .map { cellString in
          if cellString == " " {
            if numberOfCells == 0 {
              linearFirstIndex += 1
            }
            return nil
          } else if let cell = Cell(rawValue: String(cellString)) {
            numberOfCells += 1
            return cell
          }
          throw BoardError.badType
        }

      cells.append(row)
    }

    let width = cells.first?.count ?? 0

    self.width = width
    self.height = cells.count

    if linearFirstIndex == width * height {
      firstCellIndex = nil
    } else {
      firstCellIndex = (linearFirstIndex / width, linearFirstIndex % width)
    }
    self.numberOfCells = numberOfCells
  }

  func getFirstCellIndex() -> MatrixIndex? {
    for row in 0..<height {
      guard let col = cells[row].firstIndex(where: { $0 != nil }) else { continue }
      return (row, col)
    }
    return nil
  }

  var isSolvable: Bool {
    guard let firstCellIndex = firstCellIndex else { return true }

    var numReached = 0

    var cellsFound: Matrix<Bool> = .init(repeating: .init(repeating: false, count: width), count: height)

    var queue: [MatrixIndex] = [firstCellIndex]
    cellsFound[firstCellIndex] = true

    while let (row, col) = queue.popLast() {
      numReached += 1

      var potentialCandidates: [MatrixIndex] = []

      if row > 0 {
        let cellAbove = (row - 1, col)
        potentialCandidates.append(cellAbove)
      }
      if row < height - 1 {
        let cellBelow = (row + 1, col)
        potentialCandidates.append(cellBelow)
      }
      if col > 0 {
        let cellLeft = (row, col - 1)
        potentialCandidates.append(cellLeft)
      }
      if col < width - 1 {
        let cellRight = (row, col + 1)
        potentialCandidates.append(cellRight)
      }

      for candidate in potentialCandidates {
        if cells[candidate] != nil, !cellsFound[candidate] {
          queue.append(candidate)
          cellsFound[candidate] = true
        }
      }
    }

    return numReached == numberOfCells
  }

  var isSolved: Bool {
    firstCellIndex == nil
    //    cells.allSatisfy { row in row.allSatisfy { $0 == nil } }
  }

  func swap(_ move: SwapMove) throws -> Board {
    guard let cell1 = cells[move.cell1], let cell2 = cells[move.cell2], !cell1.fixed && !cell2.fixed else {
      throw BoardError.badMove
    }

    var newBoard = self

    let innerFixed = cell1.innerCell.fixed || cell2.innerCell.fixed

    var newCell1 = cell2
    if innerFixed {
      newCell1.content = .nested(outer: cell2.outerColor, inner: cell1.innerCell)
      if newCell1.outerColor == newCell1.innerCell.outerColor && !newCell1.innerCell.fixed {
        newCell1.content = .simple(newCell1.outerColor)
      }
    }

    var newCell2 = cell1
    if innerFixed {
      newCell2.content = .nested(outer: cell1.outerColor, inner: cell2.innerCell)
      if newCell2.outerColor == newCell2.innerCell.outerColor && !newCell2.innerCell.fixed {
        newCell2.content = .simple(newCell2.outerColor)
      }
    }

    newBoard.cells[move.cell1] = newCell1
    newBoard.cells[move.cell2] = newCell2

    guard newBoard.reduce() else {
      throw BoardError.badMove
    }

    return newBoard
  }

  mutating func reduce() -> Bool {
    guard let firstGroupCandidate = firstCellIndex else { return false }

    var reduced = false

    var cellsFounds: Matrix<Bool> = .init(repeating: .init(repeating: false, count: width), count: height)

    var groupCandidates: [MatrixIndex] = [firstGroupCandidate]

    while let groupCandidate = groupCandidates.popLast() {
      guard let groupColor = cells[groupCandidate]?.outerColor else { continue }

      var group: [MatrixIndex] = []

      var potentialCandidates: [MatrixIndex] = [groupCandidate]

      while let cellIndex = potentialCandidates.popLast() {
        guard let cell = cells[cellIndex], !cellsFounds[cellIndex] else {
          continue
        }

        guard cell.outerColor == groupColor else {
          groupCandidates.append(cellIndex)
          continue
        }

        cellsFounds[cellIndex] = true

        group.append(cellIndex)
        let (row, col) = cellIndex

        if row > 0 {
          let cellAbove = (row - 1, col)
          potentialCandidates.append(cellAbove)
        }
        if row < height - 1 {
          let cellBelow = (row + 1, col)
          potentialCandidates.append(cellBelow)
        }
        if col > 0 {
          let cellLeft = (row, col - 1)
          potentialCandidates.append(cellLeft)
        }
        if col < width - 1 {
          let cellRight = (row, col + 1)
          potentialCandidates.append(cellRight)
        }
      }

      if group.count >= 3 {
        reduced = true

        for cellIndex in group {
          if case let .nested(_, innerCell) = cells[cellIndex]?.content {
            cells[cellIndex] = innerCell
          } else {
            if let firstCellIndex = firstCellIndex, firstCellIndex == cellIndex {
              self.firstCellIndex = nil
            }
            cells[cellIndex] = nil
            numberOfCells -= 1
          }
        }
      }
    }

    if !reduced {
      return false
    }

    let row1Empty = cells[0].allSatisfy { $0 == nil }
    if row1Empty {
      cells.remove(at: 0)
      height -= 1
      firstCellIndex?.row -= 1
    }
    if height > 1 {
      let rowNEmpty = cells[height - 1].allSatisfy { $0 == nil }
      if rowNEmpty {
        cells.remove(at: height - 1)
        height -= 1
      }
    }
    let col1Empty = cells.allSatisfy { row in row[0] == nil }
    if col1Empty {
      for row in 0..<height {
        cells[row].remove(at: 0)
      }
      width -= 1
      firstCellIndex?.col -= 1
    }
    if width > 1 {
      let colNEmpty = cells.allSatisfy { row in row[width - 1] == nil }
      if colNEmpty {
        for row in 0..<height {
          cells[row].remove(at: width - 1)
        }
        width -= 1
      }
    }

    if firstCellIndex == nil {
      firstCellIndex = getFirstCellIndex()
    }

    return true
  }

  typealias SwapMove = (cell1: MatrixIndex, cell2: MatrixIndex)

  var solution: [SwapMove]? {
    if isSolved {
      return []
    }

    guard isSolvable else { return nil }

    var bestSolution: [SwapMove]?

    for row in 0..<height {
      for col in 0..<width {
        let cellIndex = (row, col)

        var potentialCandidates: [MatrixIndex] = []

        if row < height - 1 {
          let cellBelow = (row + 1, col)
          potentialCandidates.append(cellBelow)
        }
        if col < width - 1 {
          let cellRight = (row, col + 1)
          potentialCandidates.append(cellRight)
        }

        for candidate in potentialCandidates {
          let move: SwapMove = (cellIndex, candidate)
          if let board = try? swap(move), var solution = board.solution {
            solution = [move] + solution
            if solution.count < bestSolution?.count ?? .max {
              bestSolution = solution
            }
          }
        }
      }
    }

    return bestSolution
  }
}

extension Board: CustomStringConvertible {
  var description: String {
    var string = ""
    for row in 0..<height {
      for col in 0..<width {
        var cellString = cells[row, col].map { "\($0.rawValue)" } ?? " "
        if cellString.count == 1 {
          cellString += " "
        }
        string += cellString
        if col < width - 1 {
          string += "\t\t"
        }
      }
      if row < height - 1 {
        string += "\n"
      }
    }

    return string
  }
}
