import SwiftUI

struct ShakeEffect: GeometryEffect {
  func effectValue(size: CGSize) -> ProjectionTransform {
    return ProjectionTransform(CGAffineTransform(translationX: -5 * sin(position * 2 * .pi), y: 0))
  }

  init(shakes: Int) {
    position = CGFloat(shakes)
  }

  var position: CGFloat
  var animatableData: CGFloat {
    get { position }
    set { position = newValue }
  }
}
