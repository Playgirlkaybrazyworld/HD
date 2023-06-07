import Network
import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.modelContext) private var modelContext

  @StateObject var client = Client()
  @State private var boardSelection: BoardSelection?
  @State private var threadSelection: ThreadSelection?

  var body: some View {
    NavigationSplitView(
      sidebar: {
        BoardsListView(selection:$boardSelection)
      },
      content: {
        if let boardSelection {
          CatalogView(
            board: boardSelection.board,
            title: boardSelection.title,
            selection: $threadSelection)
          .id(boardSelection)
        } else {
          Text("Please choose a board.")
        }
      },
      detail: {
        if let boardSelection,
           let threadSelection,
           boardSelection.board == threadSelection.board {
          ThreadView(title: threadSelection.title,
                     board: threadSelection.board,
                     threadNo: threadSelection.no)
          .id(threadSelection)
        } else {
          Text("Please choose a thread.")
        }
      }
    )
    .environmentObject(client)
    .onChange(of: boardSelection) {
      if threadSelection?.board != nil &&
        threadSelection?.board != boardSelection?.board {
        threadSelection = nil
      }
    }
    .onChange(of: scenePhase) {
      switch scenePhase {
      case .active:
        try? restoreState()
      case .inactive,.background:
        saveState()
      default:
        break
      }
    }
  }
  
  func saveState() {
    // TODO
    //  try await appDatabase.updateSelection(boardId:boardSelection?.board,
    //                              threadId:threadSelection?.no)
  }
  
  // restore state if present
  func restoreState() throws {
    // TODO
//    var boardSelection: BoardSelection? = nil
//    var threadSelection: ThreadSelection? = nil
//    let appConfig = try appDatabase.reader.read { db in
//        try AppConfiguration.fetch(db)
//    }
//    if let board = appConfig.boardId {
//      let title = (try? appDatabase.reader.read { db in
//        try Board.fetchOne(db, id:board)?.title
//      }) ?? "Unknown"
//      boardSelection = BoardSelection(board:board, title: title)
//      if let threadId = appConfig.threadId {
//        var title = "Untitled"
//        if let post = try? appDatabase.reader.read({ db in
//          try Post.fetchOne(db, id:threadId)
//        }) {
//          title = post.title
//        }
//        threadSelection = ThreadSelection(board:board, title: title, no: threadId)
//      }
//    }
//    self.boardSelection = boardSelection
//    self.threadSelection = threadSelection
  }
}
