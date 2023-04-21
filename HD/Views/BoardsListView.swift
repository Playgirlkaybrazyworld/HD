import Blackbird
import FourChan
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
  @Environment(\.loader) private var loader: Loader!
  @Binding var selection: BoardSelection?
  
  @BlackbirdLiveModels<Board> var boards : Blackbird.LiveResults<Board>
  
  init(selection: Binding<BoardSelection?>, searchText: String) {
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
    // .searchable(text:$boards.like)
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
      try await loader.load(endpoint: .boards)
    } catch {
      print(error.localizedDescription)
    }
  }
}
