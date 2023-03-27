import SwiftUI

struct BlurWhenNotActiveModifier: ViewModifier {

  let radius: CGFloat
  @Environment(\.scenePhase) var scenePhase

  func body(content: Content) -> some View {
    Group {
      if case .active = scenePhase {
        content
      } else {
        content.blur(radius: radius)
      }
    }
  }
}

extension View {
  #if os(tvOS)
    func blurWhenNotActive(radius: CGFloat) -> some View {
      self
    }
  #else
    func blurWhenNotActive(radius: CGFloat) -> some View {
      self.modifier(BlurWhenNotActiveModifier(radius: radius))
    }
  #endif

}
