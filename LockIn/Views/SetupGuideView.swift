import SwiftUI

/// Walks the user through the Shortcuts automation that triggers LOCK IN.
struct SetupGuideView: View {
    private let steps = [
        "Open the Shortcuts app and go to the Automation tab.",
        "Tap +, choose App, pick Instagram (or any app), and select \"Is Opened\". Choose \"Run Immediately\".",
        "Add the action \"Should LOCK IN?\" and set the app to Instagram.",
        "Add an \"If\" action: If \"Result\" is true.",
        "Inside the If, add \"LOCK IN Pause\" and set the app to Instagram.",
        "Done. Next time you open Instagram, LOCK IN steps in first.",
    ]

    var body: some View {
        List {
            Section {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.headline)
                            .frame(width: 28, height: 28)
                            .background(.white.opacity(0.15), in: Circle())
                        Text(step)
                    }
                    .padding(.vertical, 4)
                }
            } footer: {
                Text("When you choose to open the app anyway, LOCK IN gives you a pass so the automation doesn't send you straight back here.")
            }

            Section {
                Button("Open Shortcuts") {
                    if let url = URL(string: "shortcuts://") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        .navigationTitle("Setup")
    }
}
