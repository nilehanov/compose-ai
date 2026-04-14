import SwiftUI

struct TemplatePickerView: View {
    let template: DraftTemplate
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: template.icon)
                    .font(.title2)
                    .foregroundStyle(Theme.primaryBlue)
                    .frame(width: 44, height: 44)
                    .background(Theme.primaryBlue.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    Text(template.rawValue)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(template.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}
