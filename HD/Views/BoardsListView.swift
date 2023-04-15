import Foundation
import FourChan
import Network
import SwiftUI

struct BoardSelection: Codable, Hashable {
  let board : String
  let title: String
}

struct BoardsListView: View {
  @EnvironmentObject private var client: Client
  @StateObject private var viewModel = BoardsViewModel()
  @SceneStorage("boards_search") private var searchText = ""
  @Binding var selection: BoardSelection?
  
  var body: some View {
    boards
    .listStyle(.sidebar)
    .refreshable {
      await refresh()
    }
    .searchable(text: $searchText)
    .navigationTitle("Boards")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      await refresh()
    }
  }
  
  @ViewBuilder
  var boards: some View {
    switch viewModel.boardsState {
    case .loading:
      EmptyView()
    case let .display(boards):
      List(filter(boards:boards), selection: $selection) { board in
        BoardsRowView(board:board)
          .tag(BoardSelection(board:board.id, title:board.title))
      }
    case let .error(error):
      Text("Error: \(error.localizedDescription)")
    }
  }
  
  func refresh() async {
    do {
      let boards: Boards = try await client.get(endpoint: .boards)
      withAnimation {
        viewModel.boardsState = .display(boards:boards.boards)
      }
    } catch {
      viewModel.boardsState = .error(error: error)
    }
  }
  
  func filter(boards: [Board]) -> [Board] {
    if searchText.isEmpty {
      return boards
    } else {
      return boards.filter { board in
        board.id.localizedCaseInsensitiveContains(searchText) ||
        board.title.localizedCaseInsensitiveContains(searchText)
      }
    }
  }
}
