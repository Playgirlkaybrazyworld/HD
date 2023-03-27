import SwiftUI

struct HideWhenNotActiveModifier: ViewModifier {
  @Environment(\.scenePhase) var scenePhase

  func body(content: Content) -> some View {
    content
      .opacity(scenePhase == .active ? 1.0 : 0.0)
  }
}

extension View {
  #if os(tvOS)
    func invisibleWhenNotActive() -> some View {
      self
    }
  #else
    func invisibleWhenNotActive() -> some View {
      self.modifier(HideWhenNotActiveModifier())
    }
  #endif

}
