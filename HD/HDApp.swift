import Blackbird
import SwiftUI

@main
struct HDApp: App {
  // In-memory database
  var database: Blackbird.Database = try! Blackbird.Database.inMemoryDatabase(options: [.debugPrintEveryQuery, .debugPrintEveryReportedChange, .debugPrintQueryParameterValues])
  
  // On-disk database
//    var database: Blackbird.Database = try! Blackbird.Database(path: "\(FileManager.default.temporaryDirectory.path)/blackbird-swiftui-test.sqlite", options: [.debugPrintEveryQuery, .debugPrintEveryReportedChange, .debugPrintQueryParameterValues])

  var body: some Scene {
    WindowGroup {
      ContentView()
      .environment(\.blackbirdDatabase, database)
    }
  }
}
