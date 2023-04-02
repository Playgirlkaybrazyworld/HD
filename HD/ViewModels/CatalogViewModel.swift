import Foundation
import FourChan

class CatalogViewModel : ObservableObject {
  @Published var scrollToThread: PostNumber?
  @Published var catalogState: CatalogState = .loading
  
  var scrollToThreadAnimated: Bool = false
    
  func index(thread:PostNumber)->Int? {
    if case let .display(threads) = catalogState {
      return threads.firstIndex{ $0.id == thread }
    }
    return nil
  }
}

public enum CatalogState {
  case loading
  case display(threads: [Post])
  case error(error: Error)
}
