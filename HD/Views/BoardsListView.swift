import Blackbird
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
  @Environment(\.blackbirdDatabase) var database
  @BlackbirdLiveModels<Board> var boards : Blackbird.LiveResults<Board>
  
  init(selection: Binding<BoardSelection?>, searchText:String) {
    _selection = selection
    _boards = .init({
      try await Board.read(
        from: $0,
        matching: searchText.isEmpty ? nil :
          (.like(\.$id, "%\(searchText)%") ||
            .like(\.$title, "%\(searchText)%")),
        orderBy: .ascending(\.$id)
      )
    })
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
    if boards.didLoad {
      List(boards.results, selection: $selection) { board in
        BoardsRowView(board:board)
          .tag(BoardSelection(board:board.id, title:board.title))
      }
    } else {
      EmptyView()
    }
  }
  
  func refresh() async {
    do {
      let fourChanBoards: FourChan.Boards = try await client.get(endpoint: .boards)
      let boards =
      fourChanBoards.boards.map { fourChanBoard in
        Board(id: fourChanBoard.id, title: fourChanBoard.title)
      }
      try await database!.transaction { core in
        // Remove all old rows.
        try await Board.queryIsolated(in:database!, core: core, "DELETE FROM $T")
        // Add all new rows.
        for board in boards {
          try await board.writeIsolated(to: database!, core: core)
        }
      }
    } catch {
      print(error.localizedDescription)
    }
  }
}
