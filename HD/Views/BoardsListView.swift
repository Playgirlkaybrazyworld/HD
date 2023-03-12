import Env
import Foundation
import Models
import Network
import SwiftUI

struct BoardsListView: View {
  @EnvironmentObject private var client: Client
  @State private var boards: [Board] = []
  @Binding var selection: RouterDestination?

  var body: some View {
    List(boards, selection: $selection) { board in
      NavigationLink(value: RouterDestination.catalog(board:board.id)) {
        BoardsRowView(board:board)
      }
    }
    .navigationTitle("Boards")
    .onAppear {
      Task {
        let boards: Boards = try await client.get(endpoint: .boards)
        withAnimation {
          self.boards = boards.boards
        }
      }
    }
  }
  
}
