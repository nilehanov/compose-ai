import SwiftUI

struct DraftResultView: View {
    let draft: EmailDraft
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var copied = false

    private var fullText: String {
        """
        Subject: \(draft.subjectLine)

        \(draft.greeting)

        \(draft.body)

        \(draft.closing)
        """
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Subject line
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Subject")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        Text(draft.subjectLine)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()

                    // Greeting
                    Text(draft.greeting)
                        .font(.body)

                    // Body
                    Text(draft.body)
                        .font(.body)
                        .lineSpacing(4)

                    // Closing
                    Text(draft.closing)
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Divider()

                    // Actions
                    HStack(spacing: 14) {
                        Button {
                            UIPasteboard.general.string = fullText
                            copied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                copied = false
                            }
                        } label: {
                            Label(copied ? "Copied!" : "Copy Draft", systemImage: copied ? "checkmark.circle.fill" : "doc.on.doc")
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(copied ? .green : Theme.primaryBlue)

                        ShareLink(item: fullText) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                        }
                        .buttonStyle(.bordered)
                        .tint(Theme.primaryBlue)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Your Draft")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                        onDismiss()
                    }
                }
            }
        }
    }
}
