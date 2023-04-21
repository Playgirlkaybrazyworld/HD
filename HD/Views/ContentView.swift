import Blackbird
import Network
import SwiftUI

struct ContentView: View {
  @Environment(\.scenePhase) private var scenePhase
  /// Write access to the database
  @Environment(\.blackbirdDatabase) private var blackbirdDatabase
  @BlackbirdLiveModels({ try await AppConfiguration.read(from: $0) }) var appConfiguration

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
    .onChange(of: boardSelection) { _ in
      if threadSelection?.board != nil &&
        threadSelection?.board != boardSelection?.board {
        threadSelection = nil
      }
    }
    .onChange(of:appConfiguration) { _ in
      if appConfiguration.didLoad {
        let appConfig = appConfiguration.results.first ?? AppConfiguration(id:1,boardId: nil, threadId: nil)
        var boardSelection: BoardSelection? = nil
        var threadSelection: ThreadSelection? = nil
        if let board = appConfig.boardId {
          let title = "Unknown"
          boardSelection = BoardSelection(board:board, title: title)
          if let threadId = appConfig.threadId {
            let title = "Unknown"
            threadSelection = ThreadSelection(board:board, title: title, no: threadId)
          }
        }
        self.boardSelection = boardSelection
        self.threadSelection = threadSelection
      }

    }
    .onChange(of: scenePhase) { phase in
      switch phase {
      case .inactive,.background:
        saveState()
      default:
        break
      }
    }
  }
  
  func saveState() {
    Task {
      try await AppConfiguration(id: 1, boardId: boardSelection?.board, threadId: threadSelection?.no).write(to:blackbirdDatabase!)
    }
  }
}
