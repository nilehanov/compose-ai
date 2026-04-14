import FoundationModels
import Foundation

@Observable
@MainActor
final class DraftService {
    private(set) var isGenerating = false
    private(set) var errorMessage: String?

    var isAvailable: Bool {
        switch SystemLanguageModel.default.availability {
        case .available:
            return true
        case .unavailable:
            return false
        }
    }

    var availabilityMessage: String? {
        switch SystemLanguageModel.default.availability {
        case .available:
            return nil
        case .unavailable:
            return "Apple Intelligence is not available on this device. Compose requires an iPhone or iPad with Apple Intelligence support running iOS 26 or later."
        }
    }

    func generateDraft(
        template: DraftTemplate,
        tone: Tone,
        originalMessage: String,
        intent: String
    ) async -> EmailDraft? {
        isGenerating = true
        errorMessage = nil

        defer { isGenerating = false }

        let prompt = buildPrompt(
            template: template,
            tone: tone,
            originalMessage: originalMessage,
            intent: intent
        )

        do {
            let session = LanguageModelSession()
            let response = try await session.respond(
                to: prompt,
                generating: EmailDraft.self
            )
            return response.content
        } catch {
            errorMessage = "Failed to generate draft: \(error.localizedDescription)"
            return nil
        }
    }

    private func buildPrompt(
        template: DraftTemplate,
        tone: Tone,
        originalMessage: String,
        intent: String
    ) -> String {
        var parts: [String] = []

        parts.append("You are an expert email writer. Generate a polished email draft.")
        parts.append("Tone: \(tone.rawValue) — \(tone.description).")

        switch template {
        case .replyToEmail:
            parts.append("Task: Write a reply to the following email.")
            parts.append("Original email:\n\"\"\"\n\(originalMessage)\n\"\"\"")
            parts.append("The user wants to convey: \(intent)")

        case .newEmail:
            parts.append("Task: Write a new email from scratch.")
            parts.append("Purpose: \(intent)")

        case .followUp:
            parts.append("Task: Write a follow-up email with a nudge tone.")
            parts.append("Previous thread:\n\"\"\"\n\(originalMessage)\n\"\"\"")
            parts.append("The user wants to nudge toward: \(intent)")

        case .declineReject:
            parts.append("Task: Write a polite decline/rejection email.")
            parts.append("Request being declined:\n\"\"\"\n\(originalMessage)\n\"\"\"")
            if !intent.isEmpty {
                parts.append("Additional context: \(intent)")
            }

        case .complaint:
            parts.append("Task: Write a professional complaint email.")
            parts.append("Issue description: \(intent)")
        }

        parts.append("Provide a clear subject line, appropriate greeting, well-structured body, and professional closing.")

        return parts.joined(separator: "\n\n")
    }
}
