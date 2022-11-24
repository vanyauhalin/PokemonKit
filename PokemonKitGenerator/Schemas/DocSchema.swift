import Foundation

struct DocSchemaEndpoint: Decodable {
  let name: String
  let description: String?
  let exampleRequest: String?
  let responseModels: [DocSchemaType]
}

struct DocSchemaType: Decodable {
  let name: String
  let fields: [DocSchemaField]
}

struct DocSchemaField: Decodable {
  let name: String
  let description: String
  let type: DocSchemaFieldType
}

enum DocSchemaFieldType: Decodable {
  case string(String)
  case of(DocSchemaFieldTypeOf)
  case ofType(DocSchemaFieldTypeOfType)

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if let value = try? container.decode(String.self) {
      self = .string(value)
      return
    }
    if let value = try? container.decode(DocSchemaFieldTypeOf.self) {
      self = .of(value)
      return
    }
    if let value = try? container.decode(DocSchemaFieldTypeOfType.self) {
      self = .ofType(value)
      return
    }

    throw DecodingError.typeMismatch(
      Self.self,
      DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Failed to determine doc field type"
      )
    )
  }
}

struct DocSchemaFieldTypeOf: Decodable {
  let type: String
  let of: String
}

struct DocSchemaFieldTypeOfType: Decodable {
  let type: String
  let of: DocSchemaFieldTypeOf
}

class DocSchema: PseudoCollection, Decodable {
  typealias PseudoCollectionType = [DocSchemaEndpoint]

  var collection: PseudoCollectionType

  required init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    collection = try container.decode(PseudoCollectionType.self)
  }
}

extension DocSchema {
  static let decoder: JSONDecoder = ({
    var decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  })()

  static func decode(from data: Data) throws -> Self {
    return try decoder.decode(Self.self, from: data)
  }
}
