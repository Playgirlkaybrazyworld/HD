//
//  BoardsView.swift
//  HD
//
//  Created by Jack Palevich on 3/7/23.
//

import Env
import Models
import Network
import SwiftUI

struct ContentView: View {
  @EnvironmentObject var routerPath: RouterPath

  var body: some View {
    NavigationSplitView {
      BoardsListView(selection: $routerPath.selection)
    } detail: {
      NavigationStack(path: $routerPath.path) {
        if case let .catalog(board) = routerPath.selection {
          CatalogView(board: board).id(board)
            .withAppRouter()
        } else {
          Text("Please choose a board")
        }
      }
    }
  }
}
