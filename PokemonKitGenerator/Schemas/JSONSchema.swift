// swiftlint:disable identifier_name
import Foundation

struct JSONSchemaObject<Property>: PseudoCollection, Decodable
where Property: Decodable {
  typealias PseudoCollectionType = [Property]

  private struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
      self.stringValue = stringValue
    }
    init?(intValue: Int) {
      return nil
    }
  }

  var collection: PseudoCollectionType

  init(from decoder: Decoder) throws {
    var temporally = PseudoCollectionType()
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

    try container.allKeys.forEach { key in
      guard
        let valueKey = DynamicCodingKeys(stringValue: key.stringValue)
      else {
        throw DecodingError.keyNotFound(
          key,
          DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: ""
              + "Failed to determine \(key.stringValue) dynamic key"
          )
        )
      }
      let decoded = try container.decode(Property.self, forKey: valueKey)
      temporally.append(decoded)
    }

    collection = temporally
  }
}

enum JSONSchemaType: Decodable {
  case primitive(JSONSchemaPrimitiveType)
  case multiply(JSONSchemaMultiplyType)

  typealias JSONSchemaMultiplyType = [JSONSchemaPrimitiveType]

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if let value = try? container.decode(JSONSchemaPrimitiveType.self) {
      self = .primitive(value)
      return
    }
    if let value = try? container.decode(JSONSchemaMultiplyType.self) {
      self = .multiply(value)
      return
    }

    throw DecodingError.typeMismatch(
      Self.self,
      DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Failed to determine schema field type"
      )
    )
  }
}

enum JSONSchemaPrimitiveType: String, Decodable {
  case array
  case boolean
  case integer
  case null
  case object
  case string
}

class JSONSchema: Decodable {
  typealias AnyOf = [JSONSchema]
  typealias Items = JSONSchema
  typealias Properties = JSONSchemaObject<JSONSchema>

  enum CodingKeys: String, CodingKey {
    case _ref = "$ref"
    case anyOf
    case items
    case properties
    case type
  }

  let _name: String?
  private(set) var _url: URL?
  private(set) var _breadcrumbs: [JSONSchema] = []

  private(set) var _ref: URL?
  private(set) var anyOf: AnyOf?
  private(set) var items: Items?
  private(set) var properties: Properties?
  private(set) var type: JSONSchemaType?

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if
      !container.codingPath.isEmpty,
      let property = Optional(container.codingPath[
        container.codingPath.count - 1
      ]),
      property.stringValue != "items"
    {
      _name = property.stringValue
    } else {
      _name = nil
    }

    if var ref = try? container.decode(String.self, forKey: ._ref) {
      _ref = URL(
        filePath: String(ref.dropFirst()),
        relativeTo: Loader.JSONSchemasRef
      ).absoluteURL
    } else {
      _ref = nil
    }

    anyOf = try? container.decode(AnyOf.self, forKey: .anyOf)
    items = try? container.decode(Items.self, forKey: .items)
    properties = try? container.decode(Properties.self, forKey: .properties)
    type = try? container.decode(JSONSchemaType.self, forKey: .type)

    crumble(self)
  }

  func crumble(_ schema: JSONSchema) {
    _breadcrumbs.append(schema)
    anyOf?.forEach { item in
      item.crumble(schema)
    }
    properties?.forEach { property in
      property.crumble(schema)
    }
    items?.crumble(schema)
  }

  func refer() {
    if
      let ref = _ref,
      let restored = JSONSchema.cache.first(where: { schema in
        schema._url == ref
      })
    {
      self.anyOf = restored.anyOf
      self.items = restored.items
      self.properties = restored.properties
      self.type = restored.type
    }
    anyOf?.forEach { item in
      item.refer()
    }
    properties?.forEach { property in
      property.refer()
    }
    items?.refer()
  }
}

extension JSONSchema {
  static var cache: [JSONSchema] = []

  static let decoder = JSONDecoder()

  static func decode(from data: Data) throws -> Self {
    return try decoder.decode(Self.self, from: data)
  }

  static func decode(from data: Data, at url: URL) throws -> Self {
    let schema = try decode(from: data)
    schema._url = url.absoluteURL
    cache.append(schema)
    return schema
  }
}
