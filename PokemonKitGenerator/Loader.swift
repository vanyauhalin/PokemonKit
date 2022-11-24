import Foundation

enum Loader {
  static let fileManager = FileManager.default

  static let projectDirectory = URL(
    fileURLWithPath: fileManager.currentDirectoryPath
  ).absoluteURL
  static let JSONSchemasRef = URL(
    filePath: "api-data/data/",
    relativeTo: projectDirectory
  ).absoluteURL
  static let JSONSchemasDirectory = URL(
    filePath: "api-data/data/schema/v2",
    relativeTo: projectDirectory
  ).absoluteURL
  static let docsDirectory = URL(
    filePath: "pokeapi.co/src/docs",
    relativeTo: projectDirectory
  ).absoluteURL

  static func loadJSONSchemas() throws -> [JSONSchema] {
    let urls = try findJSONSchemas(at: JSONSchemasDirectory)
    return try decodeJSONSchemas(at: urls)
  }

  static func findJSONSchemas(at url: URL) throws -> [URL] {
    guard let enumerator = fileManager.enumerator(at: url) else {
      fatalError("Failed to read the \(url)")
    }

    let resourceKeys = Set<URLResourceKey>([.isRegularFileKey])
    var files: [URL] = []

    for case let file as URL in enumerator {
      guard
        let resourceValues = try? file.resourceValues(forKeys: resourceKeys),
        let isRegularFile = resourceValues.isRegularFile,
        isRegularFile
      else {
        continue
      }
      files.append(file)
    }

    return files
  }

  static func decodeJSONSchemas(at urls: [URL]) throws -> [JSONSchema] {
    let schemas = try urls
      .map { url in
        guard let data = fileManager.contents(at: url) else {
          fatalError("Failed to read the \(url)")
        }
        return (url, data)
      }
      .map { url, data in
        try JSONSchema.decode(from: data, at: url)
      }
      .map { schema in
        schema.refer()
        return schema
      }
    JSONSchema.cache.removeAll()
    return schemas
  }

  static func loaDocs() throws -> [DocSchema] {
    let urls = try findDocs(at: docsDirectory)
    return try decodeDocs(at: urls)
  }

  static func findDocs(at url: URL) throws -> [URL] {
    let content = try fileManager.contentsOfDirectory(at: url)
    return content.filter { url in
      url.pathExtension == "json"
    }
  }

  static func decodeDocs(at urls: [URL]) throws -> [DocSchema] {
    return try urls.map { url in
      guard let data = fileManager.contents(at: url) else {
        fatalError("Failed to read the \(url)")
      }
      return try DocSchema.decode(from: data)
    }
  }

  static func loadDocEndpoints() throws -> [DocSchemaEndpoint] {
    let docs = try loaDocs()
    var endpoints: [DocSchemaEndpoint] = []
    docs.forEach { doc in
      doc.forEach { endpoint in
        endpoints.append(endpoint)
      }
    }
    return endpoints
  }

  static func loadDocTypes() throws -> [DocSchemaType] {
    let docs = try loaDocs()
    let endpoints = try loadDocEndpoints()
    var types: [DocSchemaType] = []
    endpoints.forEach { endpoint in
      endpoint.responseModels.forEach { type in
        types.append(type)
      }
    }
    return types
  }
}
