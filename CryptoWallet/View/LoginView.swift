import SwiftUI


struct LoginView: View {
    @State private var email = ""
    @State private var senha = ""

    var body: some View {
        NavigationStack{
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
                        title: "Email",
                        placeholder: "Enter your email",
                        text: $email,
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )
                    .padding(.horizontal, 24)
                    
                    LabeledTextField(
                        title: "Password",
                        placeholder: "Enter your password",
                        text: $senha,
                        isSecure: true
                    )
                    .padding(.horizontal, 24)
                    
                    PrimaryButton(title: "Sign in", action: {})
                        .padding(.horizontal, 24)
                        .padding(.top, 40)
                    
                    HStack {
                        
                        Text("Don’t have an account? ")
                            .foregroundColor(.white)
                            .opacity(0.5)
                            .multilineTextAlignment(.center)
                        
                    
                        NavigationLink("Sign up") {
                            SignUpView()
                        }.foregroundColor(.white)
                            .opacity(0.5)
                            .multilineTextAlignment(.center)
                            .underline()
                            .onTapGesture {}
                    }
                }
                .padding(.vertical, 48)
            }
        }
    }
}

#Preview {
    LoginView()
}
