import GRDB
import GRDBQuery
import FourChan
import Network
import SwiftUI

struct BoardSelection: Codable, Hashable {
  let board : String
  let title: String
}

struct BoardsListView: View {
  @EnvironmentObject private var client: Client
  @Binding var selection: BoardSelection?

  /// Write access to the database
  @Environment(\.appDatabase) private var appDatabase
  
  /// The `boards` property is automatically updated when the database changes
  @Query<BoardRequest> private var boards: [Board]

  init(selection: Binding<BoardSelection?>) {
    _selection = selection
    _boards = .init(BoardRequest(like:""))
  }
  
  var body: some View {
    boardsView
      .searchable(text:$boards.like)
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
        .tag(BoardSelection(board:board.id, title:board.title))
    }
  }
  
  func refresh() async {
    do {
      let fourChanBoards: Boards = try await client.get(endpoint: .boards)
      let boards =
      fourChanBoards.boards.map { fourChanBoard in
        Board(name: fourChanBoard.id, title: fourChanBoard.title)
      }
      try await appDatabase.update(boards:boards)
    } catch {
      print(error.localizedDescription)
    }
  }
}
