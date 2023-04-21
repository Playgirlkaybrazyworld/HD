import Blackbird

struct CatalogThread : BlackbirdModel {
  static var tableName = "Thread"
  
  static var indexes: [[BlackbirdColumnKeyPath]] = [
      [ \.$board ],
  ]

  @BlackbirdColumn var board: String
  @BlackbirdColumn var thread: Int
}
