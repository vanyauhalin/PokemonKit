import Foundation

enum SwiftConstructionType {
  case primitive(SwiftConstructionPrimitiveType)
  case optional(SwiftConstructionPrimitiveType)
  case untyped
}

enum SwiftConstructionPrimitiveType {
  case array(String)
  case boolean
  case `class`
  case integer
  case optional
  case string
}

class SwiftConstruction {
  let schema: JSONSchema
  let name: String?
  let properties: [SwiftConstruction]
  let items: SwiftConstruction?
  let type: SwiftConstructionType?

  var description: String?

  init(from schema: JSONSchema) {
    self.schema = schema
    self.name = SwiftConstruction.name(from: schema)
    self.properties = SwiftConstruction.properties(from: schema)
    self.items = SwiftConstruction.items(from: schema)
    self.type = SwiftConstruction.type(from: schema)
  }

  func flat() -> [SwiftConstruction] {
    var temporally: [SwiftConstruction] = []

    temporally.append(contentsOf: properties.flatMap { property in
      property.flat()
    })
    temporally.append(contentsOf: items?.flat() ?? [])

    switch type {
      case .primitive(let primitive):
        switch primitive {
          case .class:
            temporally.append(self)
          case .array, .boolean, .integer, .optional, .string:
            break
        }
      case .some, .none:
        break
    }

    return temporally
  }
}

extension SwiftConstruction {
  enum NameSeparator: Character {
    case `default` = "_"
    case url = "-"
  }
  enum NamePattern: String {
    case ref = ".*\\/([\\S\\s].*?).json"
    case url = ".*\\/([\\S\\s].*?)\\/\\$id\\/index.json"
  }

  static func properties(from schema: JSONSchema) -> [SwiftConstruction] {
    guard let properties = schema.properties else { return [] }
    var converted: [SwiftConstruction] = []
    properties.forEach { property in
      converted.append(SwiftConstruction(from: property))
    }
    return converted
  }

  static func items(from schema: JSONSchema) -> SwiftConstruction? {
    guard let items = schema.items else { return nil }
    return SwiftConstruction(from: items)
  }

  static func name(from schema: JSONSchema) -> String? {
    switch schema.type {
      case .primitive(let primitive):
        switch primitive {
          case .object:
            if let name = schema._name {
              return name.pascalCased(with: NameSeparator.default.rawValue)
            }
          case .array, .boolean, .integer, .null, .string:
            break
        }
      case .some, .none:
        break
    }
    if let name = schema._name {
      return name.camelCased(with: NameSeparator.default.rawValue)
    }
    if let ref = schema._ref {
      return name(from: ref, pattern: .ref, with: .default)
    }
    if let url = schema._url {
      return name(from: url, pattern: .url, with: .url)
    }
    return nil
  }

  static func name(
    from url: URL,
    pattern: NamePattern,
    with: NameSeparator
  ) -> String {
    let path = url.absoluteString
    let range = NSRange(location: .zero, length: path.count)
    let regex = try! NSRegularExpression(pattern: pattern.rawValue)
    var name = ""
    regex.matches(in: path, range: range).forEach { match in
      for rangeIndex in 0..<match.numberOfRanges {
        let matchRange = match.range(at: rangeIndex)
        guard
          matchRange != range,
          let substringRange = Range(matchRange, in: path)
        else {
          continue
        }
        name = String(path[substringRange])
      }
    }
    return name.isEmpty
      ? url.absoluteString
      : name.pascalCased(with: with.rawValue)
  }

  static func type(from schema: JSONSchema) -> SwiftConstructionType? {
    switch schema.type {
      case .primitive(let primitive):
        switch primitive {
          case .array:
            guard
              let items = SwiftConstruction.items(from: schema),
              let name = items.name
            else {
              return .untyped
            }
            return .primitive(.array(name))
          case .boolean:
            return .primitive(.boolean)
          case .integer:
            return .primitive(.integer)
          case .null:
            return .primitive(.optional)
          case .object:
            return .primitive(.class)
          case .string:
            return .primitive(.string)
        }
      case .multiply:
        return .primitive(.optional)
      case .none:
        return nil
    }
  }
}
