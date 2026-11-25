//
//  ActiveSheets.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 19/11/2026.
//

import SwiftUI

enum ActiveSheet: Identifiable {
    case importTimetable, addMenu, addClass, addDeadline, addWidget
    var id: Self { self }
}

/// The sheets behind the floating + button (the add menu and whatever it opens), shared by Today and Timetable.
/// Only one sheet can show at a time, so picking from the menu closes it and opens the choice once it's gone.
private struct AddMenuSheets: ViewModifier {
    @Binding var activeSheet: ActiveSheet?
    @State private var pendingSheet: ActiveSheet?
    @State private var showAddedPopup = false

    func body(content: Content) -> some View {
        content
            .sheet(item: $activeSheet, onDismiss: { activeSheet = pendingSheet; pendingSheet = nil }) { sheet in
                switch sheet {
                case .importTimetable:
                    ImportLinkSheet()
                        .sheetBorder()

                case .addMenu:
                    AddMenuSheet(
                        onAddClass: { open(.addClass) },
                        onAddDeadline: { open(.addDeadline) },
                        onAddWidget: { open(.addWidget) }
                    )
                    .sheetBorder(topInset: 0.4)
                    .presentationDetents([.height(350)])

                case .addClass:
                    AddClassSheet(onAdded: { showAddedPopup = true })
                        .sheetBorder()

                case .addDeadline:
                    Text("Add deadline")

                case .addWidget:
                    Text("Add widget")
                }
            }
            .PopUp(isPresented: $showAddedPopup, message: "Class added", image: "circle-check", colour: .accent)
    }

    /// Closes the add menu and opens `sheet` after it.
    private func open(_ sheet: ActiveSheet) {
        pendingSheet = sheet
        activeSheet = nil
    }
}

extension View {
    /// Presents `ActiveSheet`s, including the add menu's follow-on sheets. See `AddMenuSheets`.
    func addMenuSheets(_ activeSheet: Binding<ActiveSheet?>) -> some View {
        modifier(AddMenuSheets(activeSheet: activeSheet))
    }
}
