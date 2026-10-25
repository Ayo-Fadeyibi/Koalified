import SwiftUI
import SwiftData

struct AddAssessmentSheet: View {
    let course: Course

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var name = ""
    @State private var weight: Double?
    @State private var dueDate = Date()
    @State private var showError = false
    @State private var errorMessage = ""
    @FocusState private var focused: Field?

    enum Field { case name, weight }

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.screenPadding) {
            HStack {
                Text("Add an assessment")
                    .fontWeight(.bold)
                    .font(.title2)
                    .foregroundStyle(Color.inkPrimary)
                Spacer()
                Button { dismiss() } label: {
                    Text("Cancel")
                        .foregroundStyle(Color.accentText)
                        .fontWeight(.bold)
                }
            }

            FormField("Name") {
                TextField("e.g. Quiz 1", text: $name)
                    .focused($focused, equals: .name)
                    .submitLabel(.next)
                    .onSubmit { focused = .weight }
            }

            HStack(alignment: .top, spacing: 12) {
                FormField("Weight (%)") {
                    TextField("e.g. 20", value: $weight, format: .number)
                        .keyboardType(.decimalPad)
                        .focused($focused, equals: .weight)
                        .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
                }
                .frame(maxWidth: .infinity)

                FormField("Due date") {
                    DatePicker("Due date", selection: $dueDate, displayedComponents: .date)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
            }
            Spacer()

            PrimaryButton(title: "Save assessment", action: save)
        }
        .padding(Layout.screenPadding)
        .alert("Can't add assessment", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func fail(_ message: String) {
        errorMessage = message
        showError = true
    }

    private func save() {
        let cleanName = name.trimmingCharacters(in: .whitespaces)
        guard !cleanName.isEmpty else {
            fail("Give the assessment a name.")
            return
        }
        guard let weight, weight > 0, weight <= 100 else {
            fail("Weight must be between 0 and 100.")
            return
        }
        context.insert(AssessmentItem(title: cleanName, weight: weight,
                                      dueDate: dueDate, course: course))
        
        Task {
            _ = await NotificationScheduler.requestPermission()
            AppSync.dataChanged(in: context)
        }
        
        dismiss()
    }
}

#Preview {
    let course = try! PreviewData.container.mainContext
        .fetch(FetchDescriptor<Course>(predicate: #Predicate { $0.courseCode == "CSSE1001" }))
        .first!
    AddAssessmentSheet(course: course)
        .modelContainer(PreviewData.container)
}
