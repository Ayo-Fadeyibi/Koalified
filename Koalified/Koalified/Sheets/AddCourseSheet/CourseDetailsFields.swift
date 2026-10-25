//
//  CourseDetailsFields.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import SwiftUI

struct CourseDetailsFields: View {
    @Binding var code: String
    @Binding var name: String
    @FocusState private var focused: Field?

    enum Field { case code, name }

    var body: some View {
        VStack(spacing: 14) {
            FormField("Course code") {
                TextField("e.g. CSSE1001", text: $code)
                    .focused($focused, equals: .code)
                    .textInputAutocapitalization(.characters)
                    .submitLabel(.next)
                    .onSubmit { focused = .name }

            }
            FormField("Course name (optional)") {
                TextField("Introduction to Software Engineering", text: $name)
                    .focused($focused, equals: .name)
            }
        }
    }
}
