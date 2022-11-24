// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "PokemonKitGenerator",
  platforms: [
    .macOS(.v13)
  ],
  targets: [
    .executableTarget(
      name: "PokemonKitGenerator",
      path: ".",
      exclude: [
        "api-data",
        "Derived",
        "pokeapi.co",
        "Project.swift"
      ],
      sources: [
        "FileManager/FileManager+contents.swift",
        "FileManager/FileManager+contentsOfDirectory.swift",
        "FileManager/FileManager+enumerator.swift",
        "String/String+camelCased.swift",
        "String/String+capitalized.swift",
        "String/String+pascalCased.swift",
        "Schemas/DocSchema.swift",
        "Schemas/JSONSchema.swift",
        "Schemas/PseudoCollection.swift",
        "Loader.swift",
        "main.swift",
        "Generator.swift",
        "SwiftConstruction.swift"
      ]
    )
  ]
)
