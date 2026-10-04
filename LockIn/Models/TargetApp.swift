import AppIntents
import Foundation

/// An app LOCK IN can stand in front of.
///
/// `urlScheme` is used to send the user on to the real app once they choose
/// to continue after the pause.
enum TargetApp: String, CaseIterable, Codable, Identifiable {
    case instagram
    case tiktok
    case youtube
    case x
    case snapchat
    case reddit
    case facebook

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .instagram: "Instagram"
        case .tiktok: "TikTok"
        case .youtube: "YouTube"
        case .x: "X"
        case .snapchat: "Snapchat"
        case .reddit: "Reddit"
        case .facebook: "Facebook"
        }
    }

    var urlScheme: URL {
        switch self {
        case .instagram: URL(string: "instagram://")!
        case .tiktok: URL(string: "snssdk1233://")!
        case .youtube: URL(string: "youtube://")!
        case .x: URL(string: "twitter://")!
        case .snapchat: URL(string: "snapchat://")!
        case .reddit: URL(string: "reddit://")!
        case .facebook: URL(string: "fb://")!
        }
    }

    var symbol: String {
        switch self {
        case .instagram: "camera"
        case .tiktok: "music.note"
        case .youtube: "play.rectangle"
        case .x: "bubble.left"
        case .snapchat: "message"
        case .reddit: "text.bubble"
        case .facebook: "person.2"
        }
    }
}

extension TargetApp: AppEnum {
    // App Intents metadata is extracted at build time, so these must be literals.
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "App"

    static var caseDisplayRepresentations: [TargetApp: DisplayRepresentation] = [
        .instagram: "Instagram",
        .tiktok: "TikTok",
        .youtube: "YouTube",
        .x: "X",
        .snapchat: "Snapchat",
        .reddit: "Reddit",
        .facebook: "Facebook",
    ]
}
