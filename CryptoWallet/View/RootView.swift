import SwiftUI

struct RootView: View {
    @State private var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            ContentView(isLoggedIn: $isLoggedIn)
                .transition(.move(edge: .trailing))
        } else {
            LoginView(isLoggedIn: $isLoggedIn)
                .transition(.move(edge: .leading))
        }
    }
}

#Preview {
    RootView()
}
