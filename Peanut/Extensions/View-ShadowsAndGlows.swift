//
//  View-ShadowsAndGlows.swift
//  Peanut
//
//  Created by Adam on 10/7/21.
//

import SwiftUI

struct ViewShadowsAndGlows_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack(spacing: 50) {
                Spacer()
                VStack(spacing: 60) {
                    InShadEllipseView()
                    InShadRectangleView()
                    InShadCircleView()
                    InShadRoundedRectangleView()
                    InShadCapsuleView()
                }
                VStack(spacing: 60) {
                    GlowElipseView()
                    GlowRectangleView()
                    GlowCircleView()
                    GlowRoundedRectangleView()
                    GlowCapsuleView()
                }
                Spacer()
            }
        }
        ZStack {
            MultiColorGlowView()
        }
        ZStack {
            ThemeColorGlowView()
        }
    }
}

// MARK: - InnerShadow (InShad)

extension View {
    func innerShadow<S: Shape>(
        using shape: S,
        angle: Angle = .degrees(0),
        color: Color = .black,
        width: CGFloat = 6,
        blur: CGFloat = 6) -> some View {
            let finalX = CGFloat(cos(angle.radians - .pi / 2))
            let finalY = CGFloat(sin(angle.radians - .pi / 2))

            return self
                .overlay(
                    shape
                        .stroke(color, lineWidth: width)
                        .offset(x: finalX * width * 0.6, y: finalY * width * 0.6)
                        .blur(radius: blur)
                        .mask(shape)
                )
        }
}

struct InShadEllipseView: View {

    var body: some View {
        Ellipse()
            .fill(Color.pink)
            .frame(width: 150, height: 75)
            .innerShadow(using: Ellipse())
    }
}

struct InShadRectangleView: View {

    var body: some View {
        Rectangle()
            .fill(Color.mint)
            .frame(width: 150, height: 75)
            .innerShadow(using: Rectangle())
    }
}

struct InShadCircleView: View {

    var body: some View {
        Circle()
            .fill(Color.indigo)
            .frame(width: 100, height: 100)
            .innerShadow(using: Circle())
    }
}

struct InShadRoundedRectangleView: View {

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.brown)
            .frame(width: 150, height: 75)
            .innerShadow(using: RoundedRectangle(cornerRadius: 8))
    }
}

struct InShadCapsuleView: View {

    var body: some View {
        Capsule()
            .fill(Color.teal)
            .frame(width: 150, height: 75)
            .innerShadow(using: Capsule())
    }
}

// MARK: - Glow (func)

extension View {
    func glow(color: Color = .red, radius: CGFloat = 20) -> some View {
        self
            .overlay(self.blur(radius: radius / 6))
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
    }
}

struct GlowElipseView: View {

    var body: some View {
        Ellipse()
            .fill(Color.pink)
            .frame(width: 100, height: 50)
            .glow(color: .pink)
    }
}

struct GlowRectangleView: View {

    var body: some View {
        Rectangle()
            .fill(Color.mint)
            .frame(width: 100, height: 50)
            .glow(color: .mint)
    }
}

struct GlowCircleView: View {

    var body: some View {
        Circle()
            .fill(Color.indigo)
            .frame(width: 50, height: 50)
            .glow(color: .indigo)
    }
}

struct GlowRoundedRectangleView: View {

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.brown)
            .frame(width: 100, height: 50)
            .glow(color: .brown)
    }
}

struct GlowCapsuleView: View {

    var body: some View {
        Capsule()
            .fill(Color.teal)
            .frame(width: 100, height: 50)
            .glow(color: .teal)
    }
}

// MARK: - MultiColorGlow (func)

extension View {
    func multicolorGlow() -> some View {
        ForEach(0..<2) { image in
            RoundedRectangle(cornerRadius: 20)
                .fill(AngularGradient(
                    gradient: Gradient(
                        colors: [.red, .yellow, .green, .blue, .purple, .red]
                    ),
                    center: .center)
                )
                .frame(width: 350, height: 350)
                .mask(self.blur(radius: 20))
                .overlay(self.blur(radius: 5 - CGFloat(image * 5)))
        }
    }
}

struct MultiColorGlowView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 250, height: 250)
                .multicolorGlow()
        }
    }
}

extension View {
    func themeColorGlow() -> some View {
        ForEach(0..<2) { image in
            RoundedRectangle(cornerRadius: 20)
                .fill(AngularGradient(
                    gradient: Gradient(
                        colors: [.blue, .mint, .teal, .blue, .mint, .teal]
                    ),
                    center: .center)
                )
                .frame(width: 340, height: 340)
                .mask(self.blur(radius: 20))
                .overlay(self.blur(radius: 5 - CGFloat(image * 5)))
        }
    }
}

struct ThemeColorGlowView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill()
                .frame(width: 325, height: 325)
                .themeColorGlow()
        }
    }
}
