import Testing
@testable import Compose

@Suite("Template Tests")
struct TemplateTests {
    @Test("All templates have unique raw values")
    func uniqueRawValues() {
        let values = DraftTemplate.allCases.map(\.rawValue)
        #expect(Set(values).count == values.count)
    }

    @Test("All tones have unique raw values")
    func uniqueToneRawValues() {
        let values = Tone.allCases.map(\.rawValue)
        #expect(Set(values).count == values.count)
    }

    @Test("Template count is 5")
    func templateCount() {
        #expect(DraftTemplate.allCases.count == 5)
    }

    @Test("Tone count is 5")
    func toneCount() {
        #expect(Tone.allCases.count == 5)
    }

    @Test("Reply requires original message")
    func replyRequiresOriginal() {
        #expect(DraftTemplate.replyToEmail.requiresOriginalMessage == true)
    }

    @Test("New email does not require original message")
    func newEmailNoOriginal() {
        #expect(DraftTemplate.newEmail.requiresOriginalMessage == false)
    }

    @Test("Complaint does not require original message")
    func complaintNoOriginal() {
        #expect(DraftTemplate.complaint.requiresOriginalMessage == false)
    }

    @Test("Follow-up requires original message")
    func followUpRequiresOriginal() {
        #expect(DraftTemplate.followUp.requiresOriginalMessage == true)
    }

    @Test("Decline requires original message")
    func declineRequiresOriginal() {
        #expect(DraftTemplate.declineReject.requiresOriginalMessage == true)
    }

    @Test("Templates are Codable")
    func templateCodable() throws {
        let template = DraftTemplate.replyToEmail
        let data = try JSONEncoder().encode(template)
        let decoded = try JSONDecoder().decode(DraftTemplate.self, from: data)
        #expect(decoded == template)
    }
}
