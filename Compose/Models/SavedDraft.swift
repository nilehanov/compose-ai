import Foundation
import SwiftData

@Model
final class SavedDraft {
    var id: UUID
    var template: String
    var tone: String
    var subjectLine: String
    var greeting: String
    var body: String
    var closing: String
    var originalMessage: String
    var intent: String
    var createdAt: Date

    init(
        template: DraftTemplate,
        tone: Tone,
        draft: EmailDraft,
        originalMessage: String,
        intent: String
    ) {
        self.id = UUID()
        self.template = template.rawValue
        self.tone = tone.rawValue
        self.subjectLine = draft.subjectLine
        self.greeting = draft.greeting
        self.body = draft.body
        self.closing = draft.closing
        self.originalMessage = originalMessage
        self.intent = intent
        self.createdAt = Date()
    }

    var templateEnum: DraftTemplate? {
        DraftTemplate(rawValue: template)
    }

    var toneEnum: Tone? {
        Tone(rawValue: tone)
    }

    var fullDraftText: String {
        """
        Subject: \(subjectLine)

        \(greeting)

        \(body)

        \(closing)
        """
    }
}
