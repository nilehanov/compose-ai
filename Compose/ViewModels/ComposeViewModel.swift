import SwiftUI
import SwiftData

@Observable
@MainActor
final class ComposeViewModel {
    var selectedTemplate: DraftTemplate?
    var selectedTone: Tone = .formal
    var originalMessage: String = ""
    var intent: String = ""
    var generatedDraft: EmailDraft?
    var showResult = false

    let draftService = DraftService()

    var canGenerate: Bool {
        guard let template = selectedTemplate else { return false }
        if template.requiresOriginalMessage && originalMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        if !template.requiresOriginalMessage && intent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        return true
    }

    func generate(modelContext: ModelContext) async {
        guard let template = selectedTemplate else { return }

        let draft = await draftService.generateDraft(
            template: template,
            tone: selectedTone,
            originalMessage: originalMessage,
            intent: intent
        )

        if let draft {
            generatedDraft = draft
            showResult = true

            let saved = SavedDraft(
                template: template,
                tone: selectedTone,
                draft: draft,
                originalMessage: originalMessage,
                intent: intent
            )
            modelContext.insert(saved)
            try? modelContext.save()
        }
    }

    func reset() {
        selectedTemplate = nil
        selectedTone = .formal
        originalMessage = ""
        intent = ""
        generatedDraft = nil
        showResult = false
    }
}
