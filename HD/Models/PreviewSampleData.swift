import SwiftData
import SwiftUI

/**
 Preview sample data.
 */
actor PreviewSampleData {
    @MainActor
    static var container: ModelContainer = {
      let schema = Schema([Board.self, CatalogThread.self, Post.self, ThreadMemo.self])
        let configuration = ModelConfiguration(inMemory: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        let sampleData: [any PersistentModel] = [
          Board.preview, CatalogThread.preview, Post.preview, ThreadMemo.preview
        ]
        sampleData.forEach {
            container.mainContext.insert($0)
        }
        return container
    }()
}
