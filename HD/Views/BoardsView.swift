//
//  BoardsView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import Models
import Network
import SwiftUI

struct BoardsView: View {
  @EnvironmentObject private var client: Client
  @State private var boards: [Board] = []
  
  var body: some View {
    List(boards) {board in
      NavigationLink {
        CatalogView(board:board)
      } label: {
        BoardsRowView(board:board)
      }
    }
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

struct BoardsView_Previews: PreviewProvider {
  static var previews: some View {
    BoardsView()
      .environmentObject(Client())
  }
}
