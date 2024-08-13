//
//  main.swift
//  disassembler
//
//  Created by Saurav Mitra on 12/08/2024.
//

import AppKit
import CoreGraphics

func printSolution(_ solution: [Board.SwapMove], forBoard board: Board) {
  var board = board
  print("Solution (\(solution.count) moves):\n")
  print(board)

  func direction(from source: MatrixIndex, to destination: MatrixIndex) -> String {
    if destination.row > source.row { return "down" }
    if destination.row < source.row { return "up" }
    if destination.col > source.col { return "right" }
    if destination.col < source.col { return "left" }
    return "?"
  }

  for move in solution {
    let dir = direction(from: move.cell1, to: move.cell2)

    print()
    print("(\(move.cell1.row + 1), \(move.cell1.col + 1)) \(dir) to (\(move.cell2.row + 1), \(move.cell2.col + 1))")
    print()

    board = try! board.swap(move)

    print(board)
  }
}

//let boardString = "o.o.o"
//
//let board = try Board(boardString)
//let solution = board.solution
//
//if let solution = solution {
//  printSolution(solution, forBoard: board)
//} else {
//  print("No solution?")
//}

let screenshotURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0].appendingPathComponent("disassembler.jpg")
let outputURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0].appendingPathComponent("output.jpg")

func takeScreenshot() -> CGImage {
  let displayID = CGMainDisplayID()
  return CGDisplayCreateImage(displayID)!
}

func saveScreenshot(image: CGImage, to fileURL: URL) {
  let bitmapRep = NSBitmapImageRep(cgImage: image)
  let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!

  try! jpegData.write(to: fileURL)
}

func cropBorder(forImage image: CGImage) -> CGImage? {
  let width = image.width
  let height = image.height
  let bytesPerPixel = 4

  guard let dataProvider = image.dataProvider,
        let data = dataProvider.data,
        let pixelData = CFDataGetBytePtr(data) else {
    return nil
  }

  var minX = width
  var minY = height
  var maxX = 0
  var maxY = 0

  for y in 0..<height {
    for x in 0..<width {
      let pixelIndex = (y * width + x) * bytesPerPixel
      let red = Int(pixelData[pixelIndex])
      let green = Int(pixelData[pixelIndex + 1])
      let blue = Int(pixelData[pixelIndex + 2])

      let mean = (red + green + blue) / 3
      let meanDifference = (abs(red - green) + abs(green - blue) + abs(blue - red)) / 3

      let isBorder = mean > 200 && meanDifference < 30
      //      let isBorder = (red, green, blue) == (red: 255, green: 241, blue: 232)

      if !isBorder {
        if x < minX { minX = x }
        if x > maxX { maxX = x }
        if y < minY { minY = y }
        if y > maxY { maxY = y }
      }
    }
  }

  let croppedRect = CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)

  return image.cropping(to: croppedRect)
}

struct Color {
  let red: UInt8
  let green: UInt8
  let blue: UInt8

  init(_ red: UInt8, _ green: UInt8, _ blue: UInt8) {
    self.red = red
    self.green = green
    self.blue = blue
  }
}

func isEqualish(_ color1: Color)

func parseImage(_ image: CGImage) {
  let width = image.width
  let height = image.height
  let bytesPerPixel = 4

  guard let dataProvider = image.dataProvider,
        let data = dataProvider.data,
        let pixelData = CFDataGetBytePtr(data) else {
    return
  }

  var startingCell: (

  for y in 0..<height {
    for x in 0..<width {
      let pixelIndex = (y * width + x) * bytesPerPixel
      let red = Int(pixelData[pixelIndex])
      let green = Int(pixelData[pixelIndex + 1])
      let blue = Int(pixelData[pixelIndex + 2])


    }
  }
}

func createCGImageFromRawData(width: Int, height: Int, rawData: UnsafePointer<UInt8>) -> CGImage? {
  // Ensure rawData has the correct size
  let bytesPerPixel = 4
  let bitsPerComponent = 8
  let bytesPerRow = bytesPerPixel * width

  // Create a color space
  let colorSpace = CGColorSpaceCreateDeviceRGB()

  // Create a CGContext
  guard let context = CGContext(
    data: UnsafeMutablePointer(mutating: rawData),
    width: width,
    height: height,
    bitsPerComponent: bitsPerComponent,
    bytesPerRow: bytesPerRow,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
  ) else {
    print("Failed to create CGContext")
    return nil
  }

  // Create a CGImage from the context
  let cgImage = context.makeImage()

  return cgImage
}

Task { @MainActor in
//  try! await Task.sleep(nanoseconds: 5_000_000_000)

  mainAction()

  CFRunLoopStop(CFRunLoopGetMain())
}

func mainAction() {
  let bitmapRep = try! NSBitmapImageRep(data: Data(contentsOf: screenshotURL))!
  var image = bitmapRep.cgImage!

  let cropRect = CGRect(x: 0, y: 400, width: image.width, height: image.height)
  image = image.cropping(to: cropRect)!

  image = cropBorder(forImage: image)!

  saveScreenshot(image: image, to: outputURL)
}

CFRunLoopRun()

//229, 206, 198

//938 200 2800 1499

//937 89 1942 1094
