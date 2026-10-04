import Foundation
import Observation

/// App-wide state: settings, temporary "let me through" passes, and daily stats.
///
/// Shared between the UI and the App Intents that Shortcuts runs, so it is
/// persisted in `UserDefaults` and read fresh on every check.
@MainActor
@Observable
final class LockInStore {
    static let shared = LockInStore()

    private let defaults: UserDefaults

    /// The app the pause screen is currently shown for, if any.
    var pendingApp: TargetApp?

    /// How long the breathing pause lasts before "Open anyway" unlocks.
    var pauseSeconds: Int {
        didSet { defaults.set(pauseSeconds, forKey: Keys.pauseSeconds) }
    }

    /// How long the user can use an app after choosing to continue, before
    /// LOCK IN interrupts again. Also stops the automation looping when we
    /// open the app ourselves.
    var passMinutes: Int {
        didSet { defaults.set(passMinutes, forKey: Keys.passMinutes) }
    }

    private(set) var stats: [String: [String: Int]] {
        didSet { defaults.set(stats, forKey: Keys.stats) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let pause = defaults.integer(forKey: Keys.pauseSeconds)
        let pass = defaults.integer(forKey: Keys.passMinutes)
        pauseSeconds = pause > 0 ? pause : 10
        passMinutes = pass > 0 ? pass : 5
        stats = defaults.dictionary(forKey: Keys.stats) as? [String: [String: Int]] ?? [:]
    }

    // MARK: Passes

    func hasPass(for app: TargetApp, now: Date = .now) -> Bool {
        guard let expiry = defaults.object(forKey: Keys.pass(app)) as? Date else { return false }
        return expiry > now
    }

    func grantPass(for app: TargetApp, now: Date = .now) {
        let expiry = now.addingTimeInterval(TimeInterval(passMinutes * 60))
        defaults.set(expiry, forKey: Keys.pass(app))
    }

    // MARK: Stats

    func recordAttempt(_ app: TargetApp) { increment("attempt.\(app.rawValue)") }
    func recordResisted(_ app: TargetApp) { increment("resisted.\(app.rawValue)") }

    func attemptsToday(_ app: TargetApp? = nil) -> Int { countToday(prefix: "attempt.", app: app) }
    func resistedToday(_ app: TargetApp? = nil) -> Int { countToday(prefix: "resisted.", app: app) }

    private func increment(_ key: String) {
        var day = stats[Self.todayKey()] ?? [:]
        day[key, default: 0] += 1
        stats[Self.todayKey()] = day
    }

    private func countToday(prefix: String, app: TargetApp?) -> Int {
        let day = stats[Self.todayKey()] ?? [:]
        if let app { return day[prefix + app.rawValue] ?? 0 }
        return day.filter { $0.key.hasPrefix(prefix) }.values.reduce(0, +)
    }

    private static func todayKey(_ date: Date = .now) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private enum Keys {
        static let pauseSeconds = "pauseSeconds"
        static let passMinutes = "passMinutes"
        static let stats = "stats"
        static func pass(_ app: TargetApp) -> String { "pass.\(app.rawValue)" }
    }
}
