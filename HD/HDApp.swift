//
//  HDApp.swift
//  HD
//
//  Created by Jack Palevich on 3/6/23.
//

import Env
import Network
import SwiftUI

@main
struct HDApp: App {
  @StateObject var routerPath = RouterPath()
  @StateObject var client = Client()
    var body: some Scene {
        WindowGroup {
          ContentView()
            .environmentObject(client)
            .environmentObject(routerPath)
        }
    }
}
