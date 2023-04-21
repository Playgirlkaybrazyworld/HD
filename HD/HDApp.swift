import Blackbird
import Network
import SwiftUI

@main
struct HDApp: App {
  var database = try! Blackbird.Database.inMemoryDatabase()
  var client = Client()

  var body: some Scene {
    WindowGroup {
      ContentView()
      .environment(\.blackbirdDatabase, database)
      .environment(\.loader, Loader(database:database,client: client))
      .environmentObject(client)
    }
  }
}
