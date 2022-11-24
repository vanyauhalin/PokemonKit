import Foundation

extension FileManager {
  func enumerator(at url: URL) -> DirectoryEnumerator? {
    return self.enumerator(at: url, includingPropertiesForKeys: [])
  }
}
