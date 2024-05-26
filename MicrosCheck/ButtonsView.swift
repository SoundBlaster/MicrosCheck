import SwiftUI

struct RoundedRect: View {

    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(.white.opacity(0))
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.black.opacity(0.15), lineWidth: 4)
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(color.gradient)
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(
                            LinearGradient(stops: [Gradient.Stop(color: .bevelColor, location:0.0),
                                                   Gradient.Stop(color: .bevelColor.opacity(0.0), location:0.25),
                                                   Gradient.Stop(color: .bevelColor.opacity(0.0), location:1.0)],
                                           startPoint: UnitPoint(x: 0, y: 0),
                                           endPoint: UnitPoint(x: 0, y: 1)),
                            lineWidth: 2
                        )
                }
            )
    }
}

struct RoundedBorderedGradientRectagle: View {

    enum BevelShineStyle {
        case flat
        case top
        case bottom
        case left
        case right
    }

    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    let gradient: AnyShapeStyle
    let bevelShineStyle: BevelShineStyle

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.white.opacity(0))
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(.black.opacity(0.15), lineWidth: lineWidth * 1)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(gradient)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            bevel(),
                            lineWidth: lineWidth
                        )
                }
            )
    }

    func bevel() -> LinearGradient {
        switch bevelShineStyle {
        case .flat:
            LinearGradient(stops: [Gradient.Stop(color: .bevelColor.opacity(0.5), location:0.0),
                                   Gradient.Stop(color: .bevelColor.opacity(0.5), location:1.0)],
                           startPoint: UnitPoint(x: 0, y: 0),
                           endPoint: UnitPoint(x: 0, y: 1))
        case .top:
            LinearGradient(stops: [Gradient.Stop(color: .bevelColor, location:0.0),
                                   Gradient.Stop(color: .bevelColor.opacity(0.0), location:0.25),
                                   Gradient.Stop(color: .bevelColor.opacity(0.0), location:1.0)],
                           startPoint: UnitPoint(x: 0, y: 0),
                           endPoint: UnitPoint(x: 0, y: 1))
        case .bottom:
            LinearGradient(stops: [Gradient.Stop(color: .bevelColor.opacity(0.0), location:0.0),
                                   Gradient.Stop(color: .bevelColor.opacity(0.0), location:0.75),
                                   Gradient.Stop(color: .bevelColor, location:1.0)],
                           startPoint: UnitPoint(x: 0, y: 0),
                           endPoint: UnitPoint(x: 0, y: 1))
        case .left:
            LinearGradient(stops: [Gradient.Stop(color: .bevelColor, location:0.0),
                                   Gradient.Stop(color: .bevelColor.opacity(0.0), location:0.25),
                                   Gradient.Stop(color: .bevelColor.opacity(0.0), location:1.0)],
                           startPoint: UnitPoint(x: 0, y: 0),
                           endPoint: UnitPoint(x: 1, y: 0))
        case .right:
            LinearGradient(stops: [Gradient.Stop(color: .bevelColor.opacity(0.0), location:0.0),
                                   Gradient.Stop(color: .bevelColor.opacity(0.0), location:0.75),
                                   Gradient.Stop(color: .bevelColor, location:1.0)],
                           startPoint: UnitPoint(x: 0, y: 0),
                           endPoint: UnitPoint(x: 1, y: 0))
        }
    }
}

struct RoundedButton: View {

    enum BevelShineStyle {
        case flat
        case top
        case bottom
        case left
        case right

        func convert() -> RoundedBorderedGradientRectagle.BevelShineStyle {
            switch self {
            case .flat: return .flat
            case .top: return .top
            case .bottom: return .bottom
            case .left: return .left
            case .right: return .right
            }
        }
    }

    let icon: String
    let color: Color
    let bevelShine: BevelShineStyle
    var size: CGSize = CGSize(width: 50, height: 50)

    var body: some View {
        Button {
            print("tap")
        } label: {
            Image(systemName: icon)
                .padding()
                .foregroundColor(.white)
                .frame(width: size.width, height: size.height)
                .background(
                    RoundedBorderedGradientRectagle(cornerRadius: 50,
                                                    lineWidth: 2,
                                                    gradient: AnyShapeStyle(LinearGradient(colors: [color], startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 0, y: 1))),
                                                    bevelShineStyle: bevelShine.convert())
                )
        }
    }

}

extension Color {
    static let baseColor = Color(red: 37.0/255.0, green: 41.0/255.0, blue: 50.0/255.0)
    static let shadowColor = Color(red: 18.0/255.0, green: 19.0/255.0, blue: 25.0/255.0)
    static let bevelColor = Color(red: 49.0/255.0, green: 53.0/255.0, blue: 64.0/255.0)
}

struct ButtonsView: View {

    var body: some View {
        VStack{
            HStack {
                Spacer()

                RoundedButton(icon: "sun.max.fill",
                              color: .baseColor,
                              bevelShine: .top)

                RoundedButton(icon: "star.fill",
                              color: .baseColor,
                              bevelShine: .flat)

                RoundedButton(icon: "dial.low.fill",
                              color: .baseColor,
                              bevelShine: .bottom)
            }.padding()

            HStack {
                RoundedButton(icon: "stop.fill",
                              color: .baseColor,
                              bevelShine: .flat,
                              size: CGSize(width: 100, height: 100))
                .font(.largeTitle)
                .background(
                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                        .inset(by: -6)
                        .fill(Color.shadowColor)
                        .stroke(LinearGradient(stops: [Gradient.Stop(color: .baseColor, location:0.0),
                                                       Gradient.Stop(color: .baseColor, location:0.75),
                                                       Gradient.Stop(color: .bevelColor, location:1.0)],
                                               startPoint: UnitPoint(x: 0, y: 0),
                                               endPoint: UnitPoint(x: 0, y: 1)),
                                lineWidth: 2)
                )
                .padding()

                RoundedButton(icon: "play.fill",
                              color: .baseColor,
                              bevelShine: .flat,
                              size: CGSize(width: 100, height: 100))
                .font(.largeTitle)
                .padding()
            }
        }
        .background(Color.baseColor)
    }
}

#Preview {
    ButtonsView()
}
