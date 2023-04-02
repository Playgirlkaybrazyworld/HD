import Foundation
import FourChan

class CatalogViewModel : ObservableObject {
  @Published var scrollToThread: PostNumber?
  @Published var catalogState: CatalogState = .loading
  
  var visibleThreads = Set<PostNumber>()
  var scrollToThreadAnimated: Bool = false
  
  func appeared(thread: PostNumber) {
    visibleThreads.insert(thread)
  }
  
  func disappeared(thread: PostNumber) {
    visibleThreads.remove(thread)
  }
  
  var topVisibleThread: PostNumber? {
    visibleThreads.sorted().first
  }
  
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
