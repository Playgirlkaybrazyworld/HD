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
  @Environment(\.scenePhase) private var scenePhase
  @StateObject var routerPath = RouterPath()
  @StateObject var client = Client()
  @SceneStorage("routerPath") private var routerPathData: Data?
  
  var body: some View {
    NavigationStack(path: $routerPath.path) {
      BoardsListView()
        .withAppRouter()
    }
      .environmentObject(client)
      .environmentObject(routerPath)
      .onChange(of: scenePhase) { phase in
        switch phase {
        case .active:
          // restore state if present
          if let routerPathData = routerPathData {
            self.routerPath.restore(from: routerPathData)
          }
        case .background:
          if let updatedRouterPathData = routerPath.encoded() {
            routerPathData = updatedRouterPathData
          }
        default:
          break
        }
      }
  }
  
}
