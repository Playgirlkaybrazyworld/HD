import SwiftData

@Model
final class CatalogThread {
  @Attribute(.unique)
  var threadNo: Int
  var boardId: String
  
  @Relationship(.cascade) // TODO, inverse: \Post.threadId)
  var threads: [CatalogThread] = []
  
  @Relationship(.cascade) // TOOD, inverse: \ThreadMemo.threadId)
  var memo: ThreadMemo?
  
  init(threadNo: Int, boardId: String) {
    self.threadNo = threadNo
    self.boardId = boardId
  }
}

extension CatalogThread {
  static var preview: CatalogThread {
    let item = CatalogThread(
      threadNo: 17,
      boardId: "a")
    return item
  }
}
