import Foundation

enum Generator {
  static var constructionNames: [String] = []

  static func generateConstructions(
    from schemas: [JSONSchema]
  ) -> [SwiftConstruction] {
    return schemas
      .flatMap { schema in
        SwiftConstruction(from: schema).flat()
      }
      .filter { construction in
        guard let name = construction.name else { return true }
        guard !constructionNames.contains(name) else { return false }
        constructionNames.append(name)
        return true
      }
  }
}
