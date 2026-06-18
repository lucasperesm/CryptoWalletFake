import SwiftUI
import CoreData
 
struct WalletView: View {
   
    @ObservedObject var viewModel: WalletViewModel
    @State private var selectedTab: Tab = .all
    @Binding var selectedView: MenuOption
    @Environment(\.managedObjectContext) private var context
    @State private var currentUser: User?
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
                            .padding(EdgeInsets(top: 90, leading: 0, bottom: 0, trailing: 0))
                        Label("Olá, \(currentUser?.name ?? "User")", systemImage: "person.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white).padding(.bottom, 24)
                                        .padding(.vertical, -16)
                       
                        VStack(spacing: 10) {
                            Text(formattedTotalBalance)
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(.white)
                           
                            Text(formattedProfit)
                                .foregroundColor(viewModel.profitColor)
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
                                selectedView = .buy
                            }) {
                                ActionButton(title: "Buy", icon: "plus")
                            }
                           
                            Button(action: {
                                selectedView = .sell
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
                    }.frame(maxHeight: .infinity, alignment: .top)
                    .padding(14)
                }
        }
        .onAppear {
            carregarUsuario()
            viewModel.fetchCoinsAndMarketData()
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
 
    private var formattedTotalBalance: String {
        formatCurrency(viewModel.totalBalance)
    }
 
    private var formattedProfit: String {
        let sign = viewModel.profit >= 0 ? "+" : "-"
        let currencyValue = formatCurrency(abs(viewModel.profit))
        let percentValue = formatDecimal(abs(viewModel.profitPercentage))
        return "\(sign)\(currencyValue) (\(sign)\(percentValue)%)"
    }
 
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.numberStyle = .currency
        formatter.currencySymbol = "R$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }
 
    private func formatDecimal(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "0,00"
    }
   
    var coinsGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
       
        let coinsToShow = selectedTab == .your
        ? viewModel.coins.filter { $0.amountOwned > 0 }
        : viewModel.coins
       
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(coinsToShow) { coin in
                NavigationLink {
                    LiveCryptoView(symbol: coin.symbol.lowercased() + "usdt")
                } label: {
                    CoinCard(coin: coin)
                }
                .buttonStyle(.plain)
               
            }
           
        }
       
    }
}
 
#Preview {
    @State var selectedView = MenuOption.wallet
    WalletView(viewModel: WalletViewModel(), selectedView: $selectedView)
}
 
 
