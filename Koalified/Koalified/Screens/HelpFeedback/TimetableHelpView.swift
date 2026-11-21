import SwiftUI

/// Onboarding step 3: asks whether the user needs help finding their timetable.
/// They can be shown how, go straight to importing, or skip and finish onboarding.
struct TimetableHelpView: View {
    /// Called for "Yes, show me how".
    let onShowMe: () -> Void
    /// Called for "No, I already have it".
    let onHaveIt: () -> Void

    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
  
            Text("Do you need help finding your timetable?")
                .primaryTextStyling()
            Text("Koalified can read your UQ timetable from a link or a downloaded file. We'll show you where to find it.")
                .secondaryTextStyling()
            
            VStack(spacing: 8) {
                SecondaryButton(title: "Yes, show me how", message: "Find your timetable link or download the file", action: onShowMe)
                
                SecondaryButton(title: "No, I already have it", message: "Go straight to importing", action: onHaveIt)
                
            }
            
        }.mainContainerStyling()
    }
    
}

#Preview {
    TimetableHelpView(onShowMe: {}, onHaveIt: {})
}
