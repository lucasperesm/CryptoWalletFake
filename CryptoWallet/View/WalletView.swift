import SwiftUI

struct WalletView: View {
    
    @StateObject var viewModel = WalletViewModel()
    @State private var selectedTab: Tab = .all
    @State private var showTransactionScreen: Bool = false
    @State private var transactionMode: SellOrBuyView.Mode = .buy
    
    enum Tab {
        case your, all
    }
    
    var body: some View {
        ZStack {
            AppBackground {
                VStack(spacing: 32) {
                    
                    Text("Wallet")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    
                    VStack(spacing: 10) {
                        Text("$\(viewModel.totalBalance, specifier: "%.0f")")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                        
                        //tod add lógica para converter entre green/red com base no profit
                        Text("+$\(viewModel.profit, specifier: "%.2f")  (+\(viewModel.profitPercentage, specifier: "%.2f")%)")
                            .foregroundColor(Color.green)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Last 24 hours")
                            .foregroundColor(.gray)
                            .font(.system(size: 13))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 22)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.15))
                    )
                    
                    HStack(spacing: 14) {
                        Button(action: {
                            transactionMode = .buy
                            showTransactionScreen = true
                        }) {
                            ActionButton(title: "Buy", icon: "plus")
                        }
                        
                        Button(action: {
                            transactionMode = .sell
                            showTransactionScreen = true
                        }) {
                            ActionButton(title: "Sell", icon: "minus")
                        }
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.white.opacity(0.08))
                        
                        GeometryReader { geo in
                            let width = geo.size.width / 2
                            
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    Color(red: 88/255, green: 52/255, blue: 190/255)
                                )
                                .padding(5)
                                .frame(width: width)
                                .offset(x: selectedTab == .all ? width : 0)
                                .animation(.easeInOut(duration: 0.25), value: selectedTab)
                        }
                        
                        HStack {
                            Text("Your coins")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedTab = .your
                                }
                            
                            Text("All coins")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedTab = .all
                                }
                        }
                        .foregroundColor(.white)
                    }
                    .frame(height: 44)
                    
                    coinsGrid
                }
                .padding(14)
            }
            
            if showTransactionScreen {
                SellOrBuyView(mode: transactionMode)
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showTransactionScreen)
    }
    
    var coinsGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        
        //todo - alterar lógica quando integrado com a Binance
        let coinsToShow = selectedTab == .your
        ? viewModel.coins.filter { $0.percentage > 5 }
        : viewModel.coins
        
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(coinsToShow) { coin in
                CoinCard(coin: coin)
            }
        }
    }
}

#Preview {
    WalletView()
}


