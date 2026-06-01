import SwiftUI

struct ActionButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                    .frame(width: 26, height: 26)
                
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
            }
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 112/255, green: 70/255, blue: 227/255),
                    Color(red: 43/255, green: 7/255, blue: 144/255)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
    }
}
