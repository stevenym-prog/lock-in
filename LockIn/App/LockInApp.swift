import SwiftUI

@main
struct LockInApp: App {
    @State private var store = LockInStore.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .preferredColorScheme(.dark)
        }
    }
}

struct RootView: View {
    @Environment(LockInStore.self) private var store

    var body: some View {
        @Bindable var store = store
        HomeView()
            // Fallback trigger for automations: lockin://pause?app=instagram
            .onOpenURL { url in
                guard url.host == "pause",
                      let name = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                        .queryItems?.first(where: { $0.name == "app" })?.value,
                      let app = TargetApp(rawValue: name.lowercased())
                else { return }
                store.pendingApp = app
            }
            .fullScreenCover(item: $store.pendingApp) { app in
                PauseView(app: app)
            }
    }
}
