import SwiftUI

/// The screen that stands between the user and the app: breathe, then decide.
struct PauseView: View {
    let app: TargetApp

    @Environment(LockInStore.self) private var store
    @Environment(\.openURL) private var openURL

    @State private var remaining = Int.max
    @State private var breatheIn = false
    @State private var lockedIn = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if lockedIn {
                lockedInView
            } else {
                pauseView
            }
        }
        .task {
            store.recordAttempt(app)
            remaining = store.pauseSeconds
            // 4s in, 4s out, while counting down the pause.
            var elapsed = 0
            while !Task.isCancelled {
                if elapsed % 4 == 0 {
                    withAnimation(.easeInOut(duration: 4)) { breatheIn.toggle() }
                }
                try? await Task.sleep(for: .seconds(1))
                elapsed += 1
                if remaining > 0 { remaining -= 1 }
            }
        }
    }

    private var pauseView: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("LOCK IN")
                .font(.system(size: 44, weight: .black))
                .tracking(4)

            Circle()
                .fill(.white.opacity(0.12))
                .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 2))
                .frame(width: 180, height: 180)
                .scaleEffect(breatheIn ? 1.0 : 0.6)
                .overlay {
                    Text(remaining > 0 && remaining != .max ? "\(remaining)" : "")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }

            Text(breatheIn ? "Breathe in…" : "Breathe out…")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text(attemptLine)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    store.recordResisted(app)
                    lockedIn = true
                } label: {
                    Text("I'm good. LOCK IN.")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white, in: RoundedRectangle(cornerRadius: 16))
                        .foregroundStyle(.black)
                }

                Button {
                    store.grantPass(for: app)
                    store.pendingApp = nil
                    openURL(app.urlScheme)
                } label: {
                    Text("Open \(app.displayName) for \(store.passMinutes) min")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .disabled(remaining > 0)
                .opacity(remaining > 0 ? 0.3 : 1)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .foregroundStyle(.white)
    }

    private var lockedInView: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 64))
            Text("Locked in.")
                .font(.largeTitle.bold())
            Text("You skipped \(app.displayName) \(store.resistedToday(app)) time\(store.resistedToday(app) == 1 ? "" : "s") today.")
                .foregroundStyle(.secondary)
            Button("Done") { store.pendingApp = nil }
                .padding(.top, 24)
        }
        .foregroundStyle(.white)
    }

    private var attemptLine: String {
        let count = store.attemptsToday(app)
        return count <= 1
            ? "First time opening \(app.displayName) today."
            : "That's \(count) times opening \(app.displayName) today."
    }
}
