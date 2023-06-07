import FourChan
import Network
import SwiftData
import SwiftUI

struct BoardSelection: Codable, Hashable {
  let board : String
  let title: String
}

struct BoardsListView: View {
  @EnvironmentObject private var client: Client
  @Binding var selection: BoardSelection?

  @Environment(\.modelContext) private var modelContext

  /// The `boards` property is automatically updated when the database changes
  @Query private var boards: [Board]

  init(selection: Binding<BoardSelection?>) {
    _selection = selection
  }
  
  var body: some View {
    boardsView
      // TODO: .searchable(text:$boards.like)
      .listStyle(.sidebar)
      .refreshable {
        await refresh()
      }
      .navigationTitle("Boards")
      .navigationBarTitleDisplayMode(.inline)
      .task {
        await refresh()
      }
  }
  
  @ViewBuilder
  var boardsView: some View {
    List(boards, selection: $selection) { board in
      BoardsRowView(board:board)
        .tag(BoardSelection(board:board.name, title:board.title))
    }
  }
  
  func refresh() async {
    do {
      let fourChanBoards: Boards = try await client.get(endpoint: .boards)
      let boards =
      fourChanBoards.boards.map { fourChanBoard in
        Board(name: fourChanBoard.id, title: fourChanBoard.title)
      }
      // TODO: insert batch
      for board in boards {
        modelContext.insert(board)
      }
    } catch {
      print(error.localizedDescription)
    }
  }
}
