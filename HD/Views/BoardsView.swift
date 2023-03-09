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
  @State private var selectedBoard: Board?
  
  var body: some View {
    NavigationSplitView(sidebar: { sidebar }, detail: { detail } )
      .onAppear {
        Task {
          let boards: Boards = try await client.get(endpoint: .boards)
          withAnimation {
            self.boards = boards.boards
          }
        }
      }
      .navigationTitle("boards")
  }
  
  @ViewBuilder
  var sidebar: some View {
    List(boards, selection: $selectedBoard) { board in
      NavigationLink(value: board) {
        BoardsRowView(board:board)
      }
    }
  }
  
  @ViewBuilder
  var detail: some View {
    NavigationStack {
      if let selectedBoard = selectedBoard {
        CatalogView(board:selectedBoard)
        // ID forces the detail to refresh on iOS 16.2 simulator.
          .id(selectedBoard.id)
      } else {
        Text("Select a board from the sidebar.")
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
