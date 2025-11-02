import SwiftUI

struct RadialCountdownView: View {
    var color: Color = .green

    var total: CGFloat = 100
    var remaining: CGFloat = 100

    var body: some View {
        Canvas(
            opaque: true,
            rendersAsynchronously: false
        ) { context, size in
            let radius: CGFloat = min(size.width, size.height) * 0.48

            context.translateBy(x: size.width * 0.5, y: size.height * 0.5)
            context.rotate(by: .degrees(-90))

            let bgPath = Path { p in
                p.move(to: .zero)
                p.addArc(
                    center: .zero,
                    radius: radius,
                    startAngle: .zero,
                    endAngle: Angle(degrees: 360),
                    clockwise: false
                )
                p.closeSubpath()
            }

            context.fill(bgPath, with: .color(color.opacity(0.15)))

            let path = Path { p in
                p.move(to: .zero)
                p.addArc(
                    center: .zero,
                    radius: radius,
                    startAngle: .zero,
                    endAngle: Angle(degrees: 360) * (remaining / total),
                    clockwise: false
                )
                p.closeSubpath()
            }

            context.fill(path, with: .color(color.opacity(0.75)))
        }
    }
}

#Preview("0.75 remaining") {
    RadialCountdownView(total: 60.0, remaining: 45.0)
}

#Preview("0.5 remaining") {
    RadialCountdownView(total: 60.0, remaining: 30.0)
}

#Preview("0.25 remaining") {
    RadialCountdownView(total: 60.0, remaining: 15.0)
}

#Preview("-0.25 remaining") {
    RadialCountdownView(total: 60.0, remaining: 85.0)
}
