# LOCK IN

A screen time app for iOS. When you open Instagram, TikTok, or another app on your list, LOCK IN steps in first with a short breathing pause. You can then back out, or carry on with a timed pass.

Inspired by [one sec](https://one-sec.app).

## How it works

LOCK IN uses an iOS Shortcuts personal automation:

1. **When Instagram is opened**, the automation runs **Should LOCK IN?**
2. If the result is true, it runs **LOCK IN Pause**, which opens LOCK IN on the pause screen.
3. After the countdown, you either tap **I'm good. LOCK IN.** or open the app with a pass (5 minutes by default).
4. While the pass is active, **Should LOCK IN?** returns false, so the automation doesn't loop you back.

The URL `lockin://pause?app=instagram` also opens the pause screen if you'd rather use an "Open URL" action.

## Building

Requires Xcode 16+ and iOS 17+.

```sh
brew install xcodegen
xcodegen generate
open LockIn.xcodeproj
```

Set your development team under Signing & Capabilities, then run on your iPhone. The automations need a real device, not the simulator.

## Setting up an automation

The app has a step-by-step guide under **Set up an app**. In short:

1. Shortcuts → Automation → **+** → **App** → pick the app → **Is Opened** → **Run Immediately**
2. Add **Should LOCK IN?** (app: Instagram)
3. Add **If** Result is true
4. Inside it, add **LOCK IN Pause** (app: Instagram)

Repeat for each app you want to block.

## Project layout

```
project.yml                  XcodeGen spec
LockIn/App/                  App entry point and URL handling
LockIn/Models/               Supported apps, settings, passes, stats
LockIn/Intents/              Shortcuts actions (App Intents)
LockIn/Views/                Home, pause screen, setup guide
```

## Ideas for later

- Hard blocking with Apple's Screen Time API (FamilyControls / ManagedSettings), which needs the Family Controls entitlement from Apple
- Streaks and weekly charts
- Home screen widget with today's stats
- Custom apps beyond the built-in list
