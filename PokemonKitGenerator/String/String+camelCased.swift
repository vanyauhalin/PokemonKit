import Foundation

extension String {
  func camelCased(with separator: Character) -> String {
    split(separator: separator).reduce("") { accumulator, current in
      let formatted = accumulator.isEmpty
        ? String(current)
        : String(current).capitalized()
      return "\(accumulator)\(formatted)"
    }
  }
}
