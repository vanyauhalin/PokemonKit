import Foundation

protocol PseudoCollection {
  associatedtype PseudoCollectionType: Collection

  var collection: PseudoCollectionType { get set }
}

extension PseudoCollection {
  typealias Index = PseudoCollectionType.Index
  typealias Element = PseudoCollectionType.Element

  var startIndex: Index {
    collection.startIndex
  }
  var endIndex: Index {
    collection.endIndex
  }

  func index(after index: Index) -> Index {
    return collection.index(after: index)
  }

  @inlinable
  func forEach(_ body: (Element) throws -> Void) rethrows {
    for element in collection {
      try body(element)
    }
  }

  subscript(index: Index) -> Element {
    collection[index]
  }
}
