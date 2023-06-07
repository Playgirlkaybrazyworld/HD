import SwiftData
import SwiftUI

@main
struct HDApp: App {

  var body: some Scene {
    WindowGroup {
      ContentView()
        .modelContainer(for: [Board.self, CatalogThread.self, Post.self, ThreadMemo.self])
    }
  }
}
