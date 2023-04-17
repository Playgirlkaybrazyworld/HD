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
  @SceneStorage("boards_search") private var searchText = ""
  @Binding var selection: BoardSelection?
  
  var body: some View {
    FilteredBoardsListView(selection:_selection, searchText:searchText)
      .searchable(text: $searchText)
  }
}

struct FilteredBoardsListView: View {
  @EnvironmentObject private var client: Client
  @Binding var selection: BoardSelection?

  /// Write access to the database
  @Environment(\.appDatabase) private var appDatabase
  
  /// The `boards` property is automatically updated when the database changes
  @Query(BoardRequest(ordering: .byID)) private var boards: [Board]

  init(selection: Binding<BoardSelection?>, searchText:String) {
    _selection = selection
//    _boards = .init({
//      try await Board.read(
//        from: $0,
//        matching: searchText.isEmpty ? nil :
//          (.like(\.$id, "%\(searchText)%") ||
//            .like(\.$title, "%\(searchText)%")),
//        orderBy: .ascending(\.$id)
//      )
//    })
  }
  
  var body: some View {
    boardsView
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
