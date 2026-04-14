import SwiftUI

enum Theme {
    static let accent = Color("AccentColor", bundle: nil)
    static let primaryBlue = Color(red: 0.18, green: 0.35, blue: 0.58)
    static let secondaryBlue = Color(red: 0.30, green: 0.52, blue: 0.78)
    static let surfaceLight = Color(red: 0.96, green: 0.97, blue: 0.98)
    static let surfaceDark = Color(red: 0.12, green: 0.14, blue: 0.18)

    static func surface(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? surfaceDark : surfaceLight
    }

    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(white: 0.18) : .white
    }
}

struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding()
            .background(Theme.cardBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 6, y: 3)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
