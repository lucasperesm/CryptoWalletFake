
import Foundation
import SwiftUI

struct SellOrBuyView: View {
    enum Mode {
        case buy
        case sell
        
        var title: String {
            switch self {
            case .buy:
                return "Buy"
            case .sell:
                return "Sell"
            }
        }
    }
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = WalletViewModel()
    @State private var selectedCoin: CoinModel?
    @State private var amountInBRL: String = ""
    @State private var showFeedback: Bool = false
    
    let mode: Mode
    
    var body: some View {
        AppBackground {
            VStack(spacing: 32) {
                // MARK: - Screen Title
                Text(mode.title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 90)
                
                // Main content
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Coin Selector Section
                        CoinSelector(coins: viewModel.coins, selectedCoin: $selectedCoin)
                            .onAppear {
                                if selectedCoin == nil {
                                    selectedCoin = viewModel.coins.first
                                }
                            }
                        
                        // MARK: - Market Info Row
                        if let coin = selectedCoin {
                                HStack {
                                    Text("MARKET CAP")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Text("R$\(coin.value, specifier: "%.2fB")")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding(.horizontal, 16)
                            }
                            
                            // MARK: - Main Card
                            VStack(spacing: 20) {
                                // Balance Before Section
                                VStack(spacing: 12) {
                                    Text("Balance before")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    HStack(spacing: 16) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("R$ 1.074,32")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                            
                                            Text("Fiat balance")
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("\(selectedCoin?.symbol ?? "ETH") 0")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                            
                                            Text("Crypto balance")
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                    }
                                }
                                
                                Divider()
                                    .overlay(Color.white.opacity(0.15))
                                
                                // Amount in R$ Section
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Amount in R$")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.85))
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 6) {
                                            TextField(
                                                "0,00",
                                                text: $amountInBRL,
                                                prompt: Text("0,00").foregroundColor(.white.opacity(0.4))
                                            )
                                            .keyboardType(.decimalPad)
                                            .foregroundColor(.white)
                                            .tint(.white)
                                            .multilineTextAlignment(.trailing)
                                            
                                            Text("R$")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        .padding(.horizontal, 14)
                                        .frame(height: 44)
                                        .frame(maxWidth: 140)
                                        .background(
                                            RoundedRectangle(cornerRadius: 22)
                                                .fill(Color(red: 88/255, green: 52/255, blue: 190/255).opacity(0.35))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 22)
                                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                        )
                                    }
                                    .frame(height: 44)
                                }
                                
                                // Amount in Crypto Section
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Amount in \(selectedCoin?.name ?? "ETH")")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.85))
                                        
                                        Spacer()
                                        
                                        HStack {
                                           Spacer()
                                           if amountInBRL.isEmpty {
                                               Text("0,00")
                                                   .font(.system(size: 16, weight: .semibold))
                                                   .foregroundColor(.white.opacity(0.4))
                                           } else {
                                               Text(CoinCalculator.cryptoAmount(fromBRL: amountInBRL,
                                                     coinValue: selectedCoin?.value ?? 1))
                                                   .font(.system(size: 14, weight: .semibold))
                                                   .foregroundColor(.white)
                                           }
                                        }
                                        .padding(.horizontal, 14)
                                        .frame(height: 44)
                                        .frame(maxWidth: 140)
                                        .background(
                                            RoundedRectangle(cornerRadius: 22)
                                                .fill(Color(red: 88/255, green: 52/255, blue: 190/255).opacity(0.35))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 22)
                                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                        )
                                    }
                                    .frame(height: 44)
                                }
                                
                                Divider()
                                    .overlay(Color.white.opacity(0.15))
                                
                                // Balance After Section
                                VStack(spacing: 12) {
                                    Text("Balance after")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    HStack(spacing: 16) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(CoinCalculator.balanceAfterFiat(currentBalance: 1074.32, amountBRL: amountInBRL, isBuy: mode == .buy))
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                            
                                            Text("Fiat balance")
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text(CoinCalculator.balanceAfterCrypto(amountBRL: amountInBRL, coinValue: selectedCoin?.value ?? 1, symbol: selectedCoin?.name ?? "ETH", isBuy: mode == .buy))
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                            
                                            Text("Crypto balance")
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                    }
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 99/255, green: 57/255, blue: 249/255).opacity(0.08),
                                                Color(red: 88/255, green: 52/255, blue: 190/255).opacity(0.04)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            
                            // MARK: - Confirm Button
                            PrimaryButton(title: "Confirm", action: {
                                showFeedback = true
                            })
                        }
                        .padding(14)
                    }
                }
                .fullScreenCover(isPresented: $showFeedback) {
                    FeedbackView(mode: mode, coin: selectedCoin, amountInBRL: amountInBRL) {
                        dismiss()
                    }
                }
                .onAppear {
                    if selectedCoin == nil {
                        selectedCoin = viewModel.coins.first
                    }
                }
            }
        }
    }


#Preview {
    SellOrBuyView(mode: .buy)
}









