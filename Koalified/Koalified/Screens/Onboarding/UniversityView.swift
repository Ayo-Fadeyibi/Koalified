import SwiftUI

struct UniversityView: View {
    @State private var universityName = ""
    @FocusState private var isTextInputFocused: Bool
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            Text("Your university")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.inkPrimary)
                .padding(.bottom, 10)
            
            Text("Optional · Helps organise your planner.")
                .padding(.bottom, 15)
                .foregroundStyle(Color.inkSecondary)
            
            Text("University name")
                .fontWeight(.bold)
                .foregroundStyle(Color.inkSecondary)
            
            TextField(
                    "Enter the name of your university",
                    text: $universityName
                )
            .focused($isTextInputFocused)
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12).stroke(isTextInputFocused ? Color.inkPop : Color.cardBorder, lineWidth: 2)
            }
            Text("Enter any university name. Courses, degree rules and timetable details are added by you.")
                .foregroundStyle(Color.inkSecondary)
                .padding(.bottom, 10)
            
            Button {
                print("Clicked")
            } label: {
                Text("Continue")
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.inkPop)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button {
                print("Clicked")
            } label: {
                Text("Skip for now")
                    .fontWeight(.bold)
                    .foregroundStyle(Color.inkPop)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.inkPop))
            }
            .padding(.bottom, 15)
            
            Text("Koalified is independent. It is not an official UQ app and is not affiliated with, endorsed by, or operated by The University of Queensland.")
                .foregroundStyle(Color.inkSecondary)
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.canvas)
        
    }
}

#Preview {
    UniversityView()
}
