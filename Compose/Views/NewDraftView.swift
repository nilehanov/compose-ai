import SwiftUI
import SwiftData

struct NewDraftView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ComposeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let message = viewModel.draftService.availabilityMessage {
                        PrivacyBannerView(
                            icon: "exclamationmark.triangle.fill",
                            message: message,
                            tint: .orange
                        )
                        .padding(.horizontal)
                    }

                    if viewModel.selectedTemplate == nil {
                        templateSection
                    } else {
                        composeSection
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Compose")
            .toolbar {
                if viewModel.selectedTemplate != nil {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Back") {
                            withAnimation { viewModel.reset() }
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showResult) {
                if let draft = viewModel.generatedDraft {
                    DraftResultView(draft: draft) {
                        viewModel.reset()
                    }
                }
            }
        }
    }

    // MARK: - Template Selection

    private var templateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("What would you like to write?")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Choose a template to get started")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            PrivacyBannerView(
                icon: "lock.shield.fill",
                message: "All drafts are generated on-device using Apple Intelligence. Your messages never leave your device.",
                tint: Theme.primaryBlue
            )
            .padding(.horizontal)

            ForEach(DraftTemplate.allCases) { template in
                TemplatePickerView(template: template) {
                    withAnimation(.spring(duration: 0.35)) {
                        viewModel.selectedTemplate = template
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Compose Section

    private var composeSection: some View {
        VStack(spacing: 20) {
            if let template = viewModel.selectedTemplate {
                VStack(alignment: .leading, spacing: 6) {
                    Label(template.rawValue, systemImage: template.icon)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(template.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                TonePickerView(selectedTone: $viewModel.selectedTone)
                    .padding(.horizontal)

                if template.requiresOriginalMessage {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Original Message")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        TextEditor(text: $viewModel.originalMessage)
                            .frame(minHeight: 120)
                            .scrollContentBackground(.hidden)
                            .padding(10)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(alignment: .topLeading) {
                                if viewModel.originalMessage.isEmpty {
                                    Text(template.placeholderForOriginal)
                                        .foregroundStyle(.tertiary)
                                        .padding(.top, 18)
                                        .padding(.leading, 14)
                                        .allowsHitTesting(false)
                                }
                            }
                    }
                    .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Intent")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    TextEditor(text: $viewModel.intent)
                        .frame(minHeight: 100)
                        .scrollContentBackground(.hidden)
                        .padding(10)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(alignment: .topLeading) {
                            if viewModel.intent.isEmpty {
                                Text(template.placeholderForIntent)
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 18)
                                    .padding(.leading, 14)
                                    .allowsHitTesting(false)
                            }
                        }
                }
                .padding(.horizontal)

                generateButton
                    .padding(.horizontal)

                if let error = viewModel.draftService.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
            }
        }
    }

    private var generateButton: some View {
        Button {
            Task {
                await viewModel.generate(modelContext: modelContext)
            }
        } label: {
            Group {
                if viewModel.draftService.isGenerating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Label("Generate Draft", systemImage: "sparkles")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.primaryBlue)
        .disabled(!viewModel.canGenerate || viewModel.draftService.isGenerating || !viewModel.draftService.isAvailable)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
