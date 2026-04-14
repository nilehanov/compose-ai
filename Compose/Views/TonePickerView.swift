import SwiftUI

struct TonePickerView: View {
    @Binding var selectedTone: Tone

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tone")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Tone.allCases) { tone in
                        ToneChip(tone: tone, isSelected: selectedTone == tone) {
                            withAnimation(.spring(duration: 0.25)) {
                                selectedTone = tone
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct ToneChip: View {
    let tone: Tone
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: tone.icon)
                    .font(.caption)
                Text(tone.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(isSelected ? Theme.primaryBlue : Color(.tertiarySystemGroupedBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
