# Feedback Assistant report — SwiftUI

**Area:** SwiftUI
**Type:** Incorrect/Unexpected Behavior
**Platform / version:** iOS 27.2 (Simulator, iPhone 17, build 24B8117). Xcode with iOS 27.2 SDK.

## Title

Pushed NavigationStack destination driven only by @AppStorage re-runs body but stops redrawing children after an ancestor re-renders

## Description

A view that is pushed through `navigationDestination(for:)` and whose only dynamic property is `@AppStorage` stops applying its own updates after the first change to that key.

On every later change, the view's `body` is still called with the new value (confirmed with `print` and `Self._printChanges()`, which reports `_languageCode changed`). However, none of its child views are re-evaluated and the screen stays visually stale. The accessibility hierarchy also keeps the old `Selected` trait.

It only starts after an ancestor that reads the same `@AppStorage` key (the app's root view) re-renders on the first change.

Adding any `@State` property to the pushed view, even one that is never read, makes the problem go away completely. That is the only change needed to toggle the behaviour. The same view code shown outside a pushed destination (in an onboarding flow) works correctly.

## Steps to reproduce

1. Build and run the attached `ReproApp.swift` (single-file app) on an iOS 27.2 simulator.
2. Tap **Open Profile**, then **Language**.
3. Tap **Korean**. The highlight moves to Korean (correct).
4. Tap **Japanese**, then **Hindi**.

## Expected result

The highlighted row follows every tap.

## Actual result

Only the first tap moves the highlight. Later taps update UserDefaults, and `body` runs with the new value, but the rows never redraw. Popping back and pushing the screen again shows the correct value, and again only the first tap works.

## Workaround

Add a `@State` property to the pushed view. Uncomment the line marked `WORKAROUND` in the repro.

## Diagnostics (from the original app)

Log after tapping en → ko → ja → hi (`row body` = child view's body):

```
LSV tap en
LSV body code=en
row body isSelected=true        <- children re-render (first change only)
RootView body code=en
LSV tap ko
LSV body code=ko                <- body runs with new value...
RootView body code=ko           <- ...but no child row body is called
LSV tap ja
LSV body code=ja
RootView body code=ja
LSV tap hi
LSV body code=hi
RootView body code=hi
```

The same log with an unused `@State` added to the view shows the children re-rendering on every tap.

Things that did **not** change the behaviour:
- removing `.environment(\.locale, ...)` from the root view
- moving `navigationDestination(for:)` from the pushed Profile view to the NavigationStack root

## Attachments

- `ReproApp.swift` (minimal repro)
- Screen recording of the bug (record with: Simulator → File → Record Screen)
