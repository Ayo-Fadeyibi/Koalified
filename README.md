# Koalified

A campus app for UQ students: Today, Courses, and a target-grade calculator with hurdles. Built in SwiftUI, on-device only (no accounts, no backend) for version 1.

> Not an official UQ app. Grades and dates come from what the student enters or imports, and the ECP and Blackboard are the source of truth.

## Status
- [ ] v0.1 Prototype: tab shell, Today, Courses, course detail, marks, calculator, SwiftData storage
- [ ] v0.5 Beta: import (.ics, Excel, pasted text), calendar, widgets, reminders, TestFlight
- [ ] v1.0 App Store launch

## Tech
SwiftUI, SwiftData, WidgetKit (App Group), local notifications. iPhone only (393 pt wide design).

## Build order
1. Shell and fake data
2. Course and marks
3. Calculator (grade logic as plain Swift functions with unit tests)
4. Storage
5. Import
6. Calendar, help, widgets

## Rules
- The app never asks for or handles UQ passwords.
- No scraping behind a login.
- All user data stays on the device.
- No secrets in this repo.

## Commit style
Small commits, one idea each, for example `Add Card component` or `Add running mark function with tests`. Tag milestones `v0.1`, `v0.5`, `v1.0`.
