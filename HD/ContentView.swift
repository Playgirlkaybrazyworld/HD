//
//  ContentView.swift
//  HD
//
//  Created by Jack Palevich on 3/6/23.
//

import Models
import Network
import SwiftUI

struct ContentView: View {
  @EnvironmentObject private var client: Client
  @State private var boards: [Board] = []
  
  var body: some View {
    List(boards) {board in
      Text("\(board.id)")
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

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
    .environmentObject(Client())
  }
}
