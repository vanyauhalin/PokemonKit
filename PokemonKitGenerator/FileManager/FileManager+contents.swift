import Foundation

extension FileManager {
  func contents(at url: URL) -> Data? {
    return self.contents(atPath: url.absoluteURL.relativePath)
  }
}
