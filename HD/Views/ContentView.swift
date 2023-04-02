import Network
import SwiftUI

struct SelectionState: Codable {
  var boardSelection: BoardSelection?
  var threadSelection: ThreadSelection?
  var threadTopPost: Int?
}

struct ContentView: View {
  @Environment(\.scenePhase) private var scenePhase
  @StateObject var client = Client()
  @SceneStorage("selection") private var selectionData: Data?
  @State private var boardSelection: BoardSelection?
  @State private var threadSelection: ThreadSelection?
  @State private var threadTopPost: Int?

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
                     threadNo: threadSelection.no,
                     topPost: $threadTopPost)
          .id(threadSelection)
        } else {
          Text("Please choose a thread.")
        }
      }
    )
    .environmentObject(client)
    .onChange(of: boardSelection) { _ in
      if threadSelection?.board != boardSelection?.board {
        threadSelection = nil
      }
    }
    .onChange(of: scenePhase) { phase in
      switch phase {
      case .active:
        // restore state if present
        if let selectionData {
          let decoder = JSONDecoder()
          let selection = try? decoder.decode(SelectionState.self, from: selectionData)
          boardSelection = selection?.boardSelection
          threadSelection = selection?.threadSelection
          threadTopPost = selection?.threadTopPost
        }
      case .background,.inactive:
        let encoder = JSONEncoder()
        let selectionState =
          SelectionState(
            boardSelection:boardSelection,
            threadSelection:threadSelection,
            threadTopPost:threadTopPost
          )
        selectionData = try? encoder.encode(selectionState)
      default:
        break
      }
    }
  }
}
