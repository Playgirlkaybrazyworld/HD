import Env
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
  @State private var boardIDs: [String] = []
  @State private var boardDict: [String: Board] = [:]
  @SceneStorage("boards_search") private var searchText = ""
  @Binding var selection: BoardSelection?
  
  var body: some View {
    List(filteredBoardIDs, id:\.self, selection: $selection) { boardID in
      let board = boardDict[boardID]!
      BoardsRowView(board:board)
      .tag(BoardSelection(board:boardID, title:board.title))
    }
    .listStyle(.sidebar)
    .searchable(text: $searchText)
    .navigationTitle("Boards")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      Task {
        let boards: Boards = try await client.get(endpoint: .boards)
        withAnimation {
          boardDict = [String:Board](uniqueKeysWithValues:
                                      boards.boards.map{($0.id, $0)})
          boardIDs = boardDict.keys.sorted()
        }
      }
    }
  }
  
  var filteredBoardIDs: [String] {
    if searchText.isEmpty {
      return boardIDs
    } else {
      return boardIDs.filter { boardID in
        boardID.localizedCaseInsensitiveContains(searchText) ||
        boardDict[boardID]?.title.localizedCaseInsensitiveContains(searchText) ?? false
      }
    }
  }
}
