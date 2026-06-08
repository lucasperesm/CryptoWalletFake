
import Foundation
import SwiftUI

struct CoinSelector: View {
    let coins: [Coin]
    @Binding var selectedCoin: Coin?
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Coin")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white.opacity(0.75))

            VStack(spacing: 0) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(selectedCoin?.symbol ?? "Select a coin")
                            .foregroundColor(selectedCoin == nil ? .white.opacity(0.6) : .white)
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 99 / 255, green: 57 / 255, blue: 249 / 255).opacity(0.08),
                                        Color(red: 88 / 255, green: 52 / 255, blue: 190 / 255).opacity(0.25)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }

                if isExpanded {
                    VStack(spacing: 0) {
                        ForEach(coins) { coin in
                            Button(action: {
                                selectedCoin = coin
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isExpanded = false
                                }
                            }) {
                                HStack {
                                    Text(coin.symbol)
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .semibold))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    if selectedCoin?.id == coin.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 99 / 255, green: 57 / 255, blue: 249 / 255).opacity(0.08),
                                            Color(red: 88 / 255, green: 52 / 255, blue: 190 / 255).opacity(0.16)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color.white.opacity(0.08)),
                                alignment: .bottom
                            )
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(red: 31 / 255, green: 31 / 255, blue: 31 / 255))
                            .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 8)
                    )
                }
            }
        }
    }
}

#Preview {
    CoinSelector(coins: [
        Coin(name: "ETH", symbol: "Ethereum", value: 10545.25, percentage: 49, icon: "e.circle"),
        Coin(name: "BTC", symbol: "Bitcoin", value: 262515.351, percentage: 10, icon: "bitcoinsign.circle"),
        Coin(name: "BNB", symbol: "Binance", value: 42, percentage: 1, icon: "b.circle")
    ], selectedCoin: .constant(nil))
}

