import SwiftUI
import SwiftData

struct DraftListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedDraft.createdAt, order: .reverse) private var drafts: [SavedDraft]
    @State private var selectedDraft: SavedDraft?

    var body: some View {
        NavigationStack {
            Group {
                if drafts.isEmpty {
                    ContentUnavailableView(
                        "No Drafts Yet",
                        systemImage: "tray",
                        description: Text("Drafts you generate will appear here.")
                    )
                } else {
                    List {
                        ForEach(drafts) { draft in
                            DraftRow(draft: draft)
                                .onTapGesture {
                                    selectedDraft = draft
                                }
                        }
                        .onDelete(perform: deleteDrafts)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("History")
            .sheet(item: $selectedDraft) { draft in
                SavedDraftDetailView(draft: draft)
            }
        }
    }

    private func deleteDrafts(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(drafts[index])
        }
        try? modelContext.save()
    }
}

private struct DraftRow: View {
    let draft: SavedDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if let template = draft.templateEnum {
                    Label(template.rawValue, systemImage: template.icon)
                        .font(.caption)
                        .foregroundStyle(Theme.primaryBlue)
                }
                Spacer()
                if let tone = draft.toneEnum {
                    Text(tone.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.primaryBlue.opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            Text(draft.subjectLine)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)

            Text(draft.body)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Text(draft.createdAt, style: .relative)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

private struct SavedDraftDetailView: View {
    let draft: SavedDraft
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
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

                    Text(draft.greeting)
                    Text(draft.body)
                        .lineSpacing(4)
                    Text(draft.closing)
                        .foregroundStyle(.secondary)

                    Divider()

                    Button {
                        UIPasteboard.general.string = draft.fullDraftText
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
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Draft Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
