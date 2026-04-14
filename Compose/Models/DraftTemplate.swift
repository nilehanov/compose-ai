import Foundation

enum DraftTemplate: String, CaseIterable, Identifiable, Codable, Sendable {
    case replyToEmail = "Reply to Email"
    case newEmail = "New Email"
    case followUp = "Follow-Up"
    case declineReject = "Decline / Reject"
    case complaint = "Complaint"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .replyToEmail: return "arrowshape.turn.up.left.fill"
        case .newEmail: return "envelope.fill"
        case .followUp: return "bell.fill"
        case .declineReject: return "hand.raised.fill"
        case .complaint: return "exclamationmark.bubble.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .replyToEmail: return "Craft a reply to a received email"
        case .newEmail: return "Write a brand-new email from scratch"
        case .followUp: return "Send a polite follow-up nudge"
        case .declineReject: return "Decline a request gracefully"
        case .complaint: return "File a professional complaint"
        }
    }

    var requiresOriginalMessage: Bool {
        switch self {
        case .replyToEmail, .followUp, .declineReject: return true
        case .newEmail, .complaint: return false
        }
    }

    var placeholderForOriginal: String {
        switch self {
        case .replyToEmail: return "Paste the email you received..."
        case .followUp: return "Paste the email thread so far..."
        case .declineReject: return "Paste the request you want to decline..."
        default: return ""
        }
    }

    var placeholderForIntent: String {
        switch self {
        case .replyToEmail: return "What do you want to convey in your reply?"
        case .newEmail: return "Describe the purpose of this email..."
        case .followUp: return "What outcome are you nudging toward?"
        case .declineReject: return "Any specific reason or softener to include?"
        case .complaint: return "Describe the issue you want to raise..."
        }
    }
}

enum Tone: String, CaseIterable, Identifiable, Codable, Sendable {
    case formal = "Formal"
    case friendly = "Friendly"
    case assertive = "Assertive"
    case diplomatic = "Diplomatic"
    case apologetic = "Apologetic"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .formal: return "building.columns.fill"
        case .friendly: return "face.smiling.fill"
        case .assertive: return "bolt.fill"
        case .diplomatic: return "handshake.fill"
        case .apologetic: return "heart.fill"
        }
    }

    var description: String {
        switch self {
        case .formal: return "Professional and businesslike"
        case .friendly: return "Warm and approachable"
        case .assertive: return "Direct and confident"
        case .diplomatic: return "Tactful and balanced"
        case .apologetic: return "Sincere and regretful"
        }
    }
}
