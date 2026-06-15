import SwiftUI

struct LoginView: View {

    @Binding var isLoggedIn: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                VStack(spacing: 28) {
                    LogoCriptoWallet(size: 90)
                    Spacer()
                    
                    Text("Login")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 16)
                    
                    LabeledTextField(
                        title: "E-mail",
                        placeholder: "Enter your email",
                        text: $viewModel.email,
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )
                    .padding(.horizontal, 24)
                    
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
                    
                    PrimaryButton(title: "Sign in", action: {
                        viewModel.login(context: viewContext)
                    })
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    
                    HStack {
                        Text("Don’t have an account? ")
                            .foregroundColor(.white)
                            .opacity(0.5)
                        
                        NavigationLink("Sign up") {
                            SignUpView()
                        }
                        .foregroundColor(.white)
                        .opacity(0.5)
                        .underline()
                    }
                }
                .padding(.vertical, 48)
            }
        }
        .onChange(of: viewModel.isLogged) { oldValue, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLoggedIn = true
                }
            }
        }
    }
}

//#Preview {
//    @State var isLoggedIn = false
//    return LoginView(isLoggedIn: $isLoggedIn)
//}
