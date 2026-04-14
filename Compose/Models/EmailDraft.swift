import FoundationModels

@Generable
struct EmailDraft: Codable, Sendable {
    /// The subject line for the email
    @Guide(description: "A concise, clear email subject line")
    var subjectLine: String

    /// The greeting / salutation
    @Guide(description: "An appropriate greeting such as 'Dear [Name],' or 'Hi [Name],'")
    var greeting: String

    /// The main body of the email
    @Guide(description: "The main content of the email, well-structured with clear paragraphs")
    var body: String

    /// The closing / sign-off
    @Guide(description: "A professional closing such as 'Best regards,' or 'Sincerely,'")
    var closing: String
}
