import SwiftData

@Model
final class Board {
  @Attribute(.unique)
  var name: String
  var title: String
  @Relationship(.cascade) // TOOD , inverse: \CatalogThread.boardId
  var threads: [CatalogThread] = []
  
  init(name: String, title: String) {
    self.name = name
    self.title = title
  }
}

extension Board {
    static var preview: Board {
        let item = Board(
            name: "a",
            title: "The A board")
        return item
    }
}
