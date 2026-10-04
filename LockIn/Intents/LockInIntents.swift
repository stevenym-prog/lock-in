import AppIntents

/// Step 1 of the automation: "should LOCK IN interrupt this app right now?"
///
/// Returns `false` while the user holds a pass for the app (they just chose
/// to continue), which is what stops the automation from looping when LOCK IN
/// opens the app for them.
struct ShouldLockInIntent: AppIntent {
    static let title: LocalizedStringResource = "Should LOCK IN?"
    static let description = IntentDescription(
        "Returns true if LOCK IN should interrupt the app. Use it in an \"App is opened\" automation."
    )

    @Parameter(title: "App")
    var app: TargetApp

    static var parameterSummary: some ParameterSummary {
        Summary("Should LOCK IN interrupt \(\.$app)?")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        .result(value: !LockInStore.shared.hasPass(for: app))
    }
}

/// Step 2 of the automation: open LOCK IN on the pause screen for the app.
struct LockInPauseIntent: AppIntent {
    static let title: LocalizedStringResource = "LOCK IN Pause"
    static let description = IntentDescription("Opens LOCK IN and shows the pause screen for the app.")
    static let openAppWhenRun = true

    @Parameter(title: "App")
    var app: TargetApp

    static var parameterSummary: some ParameterSummary {
        Summary("Pause before opening \(\.$app)")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        LockInStore.shared.pendingApp = app
        return .result()
    }
}

struct LockInShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LockInPauseIntent(),
            phrases: ["Pause with \(.applicationName)"],
            shortTitle: "LOCK IN Pause",
            systemImageName: "lock.fill"
        )
    }
}
