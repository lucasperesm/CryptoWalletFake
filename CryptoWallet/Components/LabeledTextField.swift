import SwiftUI

private let labelBackgroundColor = Color(red: 0.07, green: 0.06, blue: 0.15)

struct LabeledTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
                .frame(height: 60)
                .padding(.top, 10)

            Group {
                if isSecure {
                    SecureField(
                        "",
                        text: $text,
                        prompt: Text(placeholder).foregroundColor(.white.opacity(0.4))
                    )
                } else {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text(placeholder).foregroundColor(.white.opacity(0.4))
                    )
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                }
            }
            .foregroundColor(.white)
            .tint(.white)
            .padding(.horizontal, 16)
            .frame(height: 60)
            .padding(.top, 10)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))
                .padding(.horizontal, 6)
                .background(labelBackgroundColor)
                .padding(.leading, 16)
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.07, green: 0.06, blue: 0.15).ignoresSafeArea()
        LabeledTextField(title: "E-mail", placeholder: "Digite seu e-mail", text: .constant(""))
            .padding()
    }
}
