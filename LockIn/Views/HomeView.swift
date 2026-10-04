import SwiftUI

struct HomeView: View {
    @Environment(LockInStore.self) private var store

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            List {
                Section {
                    HStack {
                        stat("\(store.attemptsToday())", "attempts")
                        Divider()
                        stat("\(store.resistedToday())", "locked in")
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Today")
                }

                Section("Settings") {
                    Stepper("Pause: \(store.pauseSeconds)s", value: $store.pauseSeconds, in: 3...60)
                    Stepper("Pass: \(store.passMinutes) min", value: $store.passMinutes, in: 1...60)
                }

                Section {
                    NavigationLink("Set up an app") { SetupGuideView() }
                }

                Section("Apps") {
                    ForEach(TargetApp.allCases) { app in
                        HStack {
                            Label(app.displayName, systemImage: app.symbol)
                            Spacer()
                            Text("\(store.attemptsToday(app))")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                }
            }
            .navigationTitle("LOCK IN")
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack {
            Text(value).font(.system(size: 36, weight: .bold, design: .rounded))
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
