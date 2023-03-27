import Env
import Foundation
import FourChan
import Network
import SwiftUI

struct BoardsListView: View {
  @EnvironmentObject private var client: Client
  @State private var boardIDs: [String] = []
  @State private var boardDict: [String: Board] = [:]
  @State var selection: String?
  @SceneStorage("boards_search") private var searchText = ""

  var body: some View {
    List(filteredBoardIDs, id:\.self, selection: $selection) { boardID in
      NavigationLink(value: RouterDestination.catalog(board: boardID)) {
        BoardsRowView(board:boardDict[boardID]!)
      }
    }
    .searchable(text: $searchText)
    .navigationTitle("Boards")
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
