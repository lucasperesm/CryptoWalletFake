import SwiftUI

struct SignUpView: View {
    @State private var nome = ""
    @State private var email = ""
    @State private var senha = ""

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 28) {
                
                LogoCriptoWallet(size: 90)
                Spacer()
                
                Text("Create account")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)

                LabeledTextField(
                    title: "Name",
                    placeholder: "Enter your name",
                    text: $nome
                )
                .padding(.horizontal, 24)

                LabeledTextField(
                    title: "E-mail",
                    placeholder: "Enter your email",
                    text: $email,
                    keyboardType: .emailAddress,
                    autocapitalization: .never
                )
                .padding(.horizontal, 24)
                .padding(.top, 24)

                LabeledTextField(
                    title: "Password",
                    placeholder: "Enter your password",
                    text: $senha,
                    isSecure: true
                )
                .padding(.horizontal, 24)
                .padding(.top, 24)

                PrimaryButton(title: "Create", action: {})
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
            }
            .padding(.vertical, 48)
        }
    }
}

#Preview {
    SignUpView()
}
