import Foundation

extension FileManager {
  func contentsOfDirectory(at url: URL) throws -> [URL] {
    return try self.contentsOfDirectory(at: url, includingPropertiesForKeys: [])
  }
}
