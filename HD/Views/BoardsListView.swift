import Env
import Foundation
import Models
import Network
import SwiftUI

struct BoardsListView: View {
  @EnvironmentObject private var client: Client
  @State private var boardIDs: [String] = []
  @State private var boardDict: [String: Board] = [:]
  @Binding var selection: String?

  var body: some View {
    List(boardIDs, id:\.self, selection: $selection) { boardID in
      NavigationLink(value: RouterDestination.catalog(board:boardID)) {
        BoardsRowView(board:boardDict[boardID]!)
      }
    }
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
  
}
