import SwiftUI

struct SignUpView: View {
 
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = RegisterViewModel()

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
                    text: $viewModel.name
                )
                .padding(.horizontal, 24)

                LabeledTextField(
                    title: "E-mail",
                    placeholder: "Enter your email",
                    text: $viewModel.email,
                    keyboardType: .emailAddress,
                    autocapitalization: .never
                )
                .padding(.horizontal, 24)
                .padding(.top, 24)

                LabeledTextField(
                    title: "Password",
                    placeholder: "Enter your password",
                    text: $viewModel.password,
                    isSecure: true
                )
                .padding(.horizontal, 24)
                .padding(.top, 24)

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 14, weight: .semibold))
                }

                PrimaryButton(title: "Create", action: {
                    viewModel.cadastrar(context: viewContext)
                })
                .padding(.horizontal, 24)
                .padding(.top, 40)
            }
            .padding(.vertical, 48)
        }
        .onChange(of: viewModel.sucess) { oldValue, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}

#Preview {
    SignUpView()
}
