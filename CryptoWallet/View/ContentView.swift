import SwiftUI
 
struct ContentView: View {
    @State private var menuOpen: Bool = false
    @State private var selectedView: MenuOption = .wallet
    @StateObject private var walletViewModel = WalletViewModel()
    @Binding var isLoggedIn: Bool
   
    var body: some View {
        ZStack {
            // Cada view tem seu próprio NavigationStack
            if selectedView == .wallet {
                NavigationStack {
                    WalletView(viewModel: walletViewModel, selectedView: $selectedView)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        menuOpen.toggle()
                                    }
                                }) {
                                    Image(systemName: "line.3.horizontal")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                }
                .id("wallet")
            } else if selectedView == .buy {
                NavigationStack {
                    SellOrBuyView(viewModel: walletViewModel, selectedView: $selectedView, mode: .buy)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        menuOpen.toggle()
                                    }
                                }) {
                                    Image(systemName: "line.3.horizontal")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                }
                .id("buy")
            } else if selectedView == .sell {
                NavigationStack {
                    SellOrBuyView(viewModel: walletViewModel, selectedView: $selectedView, mode: .sell)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        menuOpen.toggle()
                                    }
                                }) {
                                    Image(systemName: "line.3.horizontal")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                }
                .id("sell")
            } else if selectedView == .liveCrypto {
                NavigationStack {
                    LiveCryptoView()
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        menuOpen.toggle()
                                    }
                                }) {
                                    Image(systemName: "line.3.horizontal")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                }
                .id("liveCrypto")
            }
           
            // Menu lateral
            SideMenuView(isOpen: $menuOpen, selectedView: $selectedView, onLogout: {
                isLoggedIn = false
            })
        }
    }
}
 
#Preview {
    @State var isLoggedIn = true
    return ContentView(isLoggedIn: $isLoggedIn)
}
