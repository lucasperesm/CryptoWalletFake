import SwiftUI

struct ContentView: View {
    @State private var nome = ""
    @State private var email = ""
    @State private var senha = ""

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 28) {
                Text("Create account")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)

                LabeledTextField(
                    title: "Nome",
                    placeholder: "Digite seu nome",
                    text: $nome
                )
                .padding(.horizontal, 24)
                .padding(.top, 40)

                LabeledTextField(
                    title: "E-mail",
                    placeholder: "Digite seu e-mail",
                    text: $email,
                    keyboardType: .emailAddress,
                    autocapitalization: .never
                )
                .padding(.horizontal, 24)

                LabeledTextField(
                    title: "Senha",
                    placeholder: "Digite sua senha",
                    text: $senha,
                    isSecure: true
                )
                .padding(.horizontal, 24)

                PrimaryButton(title: "Create", action: {})
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
            }
            .padding(.vertical, 48)
        }
    }
}

#Preview {
    ContentView()
}
