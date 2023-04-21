import Blackbird

struct CatalogThread : BlackbirdModel {
  static var tableName = "Thread"
  @BlackbirdColumn var board: String
  @BlackbirdColumn var thread: Int
}
