import FourChan

extension Post {
  func contains(text : String) -> Bool {
    // TODO: deal with HTML escaping.
    if let sub, sub.localizedCaseInsensitiveContains(text) {
      return true
    }
    if let com, com.localizedCaseInsensitiveContains(text) {
      return true
    }
    return false
  }
}
