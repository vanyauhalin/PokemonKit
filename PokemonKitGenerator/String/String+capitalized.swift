import Foundation

extension String {
  func capitalized() -> String {
    prefix(1).uppercased() + lowercased().dropFirst()
  }
}
