import SwiftUI
import CoreData

struct SideMenuView: View {
    @Binding var isOpen: Bool
    @Binding var selectedView: MenuOption
    var onLogout: (() -> Void)? = nil
    
    @Environment(\.managedObjectContext) private var context
    @State private var currentUser: User?
    

            
    var body: some View {
        ZStack {
            // Overlay semi-transparente
            if isOpen {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isOpen = false
                        }
                    }
            }
    
            // Menu Lateral
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header do Menu
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            LogoCriptoWallet()
                                .padding(.top, 36)
                            Spacer()
                            
                            
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isOpen = false
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                       
                    }
                    .padding(20)
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 54))
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            
                            // Pegar o nome do usuário logado do core data e mostrar no menu
                            
                            Label("Olá, \(currentUser?.name ?? "User")", systemImage: "person.circle.fill")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white).padding(.horizontal, 16)
                                            .padding(.bottom, 30)
                        
                            
                            // MARK: - Wallet Option
                            VStack(spacing: 0) {
                                Button(action: {
                                    selectedView = .wallet
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isOpen = false
                                    }
                                }) {
                                    HStack {
                                        Label("My Wallet", systemImage: "wallet.bifold")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                    .contentShape(Rectangle())
                                }
                                .padding(.horizontal, 28)
                                .padding(.vertical, 12)
                            }
                            // MARK: - Buy Option
                            Button(action: {
                                selectedView = .buy
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isOpen = false
                                }
                            }) {
                                HStack {
                                    Label("Buy", systemImage: "bag")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            // MARK: - Sell Option
                            Button(action: {
                                selectedView = .sell
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isOpen = false
                                }
                            }) {
                                HStack {
                                    Label("Sell", systemImage: "tag")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                            .background(Color.white.opacity(0.5))
                            .padding(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 54))
                        
                        Button(action: {
                        onLogout?()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isOpen = false
                            }
                        }) {
                        HStack {
                            Label("Logout", systemImage: "arrow.backward")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    }
                }
                    
                .frame(maxWidth: 280)
                .background(
                    ZStack {
                        Color.clear
                            .glassEffect(.regular, in: .rect(cornerRadius: 24.0))
                        
                        Color.black
                            .opacity(0.8)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(x: isOpen ? 0 : -320)
            .animation(.easeInOut(duration: 0.3), value: isOpen)
        }
        .ignoresSafeArea()
        .onAppear {
            carregarUsuario()
        }
    }
    
    private func carregarUsuario() {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.fetchLimit = 1
        
        do {
            currentUser = try context.fetch(request).first
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    @State var isOpen = true
    @State var selectedView = MenuOption.wallet
    
    return ZStack {
        Color.black.ignoresSafeArea()
        
        SideMenuView(isOpen: $isOpen, selectedView: $selectedView)
    }
}
