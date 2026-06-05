import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.3, blue: 0.95),
                            Color(red: 0.3, green: 0.1, blue: 0.75)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(14)
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.07, green: 0.06, blue: 0.15).ignoresSafeArea()
        PrimaryButton(title: "Create", action: {})
            .padding()
    }
}
