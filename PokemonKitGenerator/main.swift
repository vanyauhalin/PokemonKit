import Foundation

#if DEBUG
Loader.fileManager.changeCurrentDirectoryPath(
  ProcessInfo.processInfo.environment["CURRENT_DIRECTORY_PATH"]
)
#endif

func main() throws {
  let schemas = try Loader.loadJSONSchemas()
  let constructions = Generator.generateConstructions(from: schemas)
  let docs = try Loader.loadDocTypes()

  docs.forEach { doc in
    let construction = constructions.first(where: { construction in
      construction.name == doc.name
    })
    print(construction)
  }

  let names = docs.map { doc in
    doc.name
  }

  constructions
    .filter { construction in
      if let name = construction.name {
        return !name.contains(".json")
      }
      return true
    }
    .forEach { construction in
      let properties = construction.properties.map { property in
        property.schema._name
      }
      if construction.name == nil {
        construction
      }
    }
}

try main()
