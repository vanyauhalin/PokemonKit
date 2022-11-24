import Foundation

extension String {
  func pascalCased(with separator: Character) -> String {
    prefix(1).uppercased() + camelCased(with: separator).dropFirst()
  }
}
