

import Foundation
import SwiftUI

struct FeedbackView: View {
    let mode: SellOrBuyView.Mode
    let coin: CoinModel?
    let amountInBRL: String
    let onReturn: () -> Void

    private var titleText: String {
        switch mode {
        case .buy:
            return "Purchase Completed"
        case .sell:
            return "Sale Completed"
        }
    }

    private var subtitleText: String {
        let coinName = coin?.symbol ?? "Crypto"
        return mode == .buy
            ? "You successfully bought \(coinName)"
            : "You successfully sold \(coinName)"
    }

    private var amountText: String {
        guard !amountInBRL.isEmpty else { return "" }
        return "R$ \(amountInBRL)"
    }

    var body: some View {
        ZStack {
            AppBackground {
                Color.clear
            }

            VStack(spacing: 28) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 99 / 255, green: 57 / 255, blue: 249 / 255).opacity(0.25),
                                        Color(red: 88 / 255, green: 52 / 255, blue: 190 / 255).opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)

                        Image(systemName: mode == .buy ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                            .font(.system(size: 56))
                            .foregroundColor(.white)
                    }

                    Text(titleText)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(subtitleText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    if !amountText.isEmpty {
                        Text(amountText)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(red: 88 / 255, green: 52 / 255, blue: 190 / 255).opacity(0.35))
                            )
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 99 / 255, green: 57 / 255, blue: 249 / 255).opacity(0.07),
                                    Color(red: 88 / 255, green: 52 / 255, blue: 190 / 255).opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )

                PrimaryButton(title: "Back to Wallet", action: onReturn)
                    .padding(.horizontal, 20)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    FeedbackView(mode: .buy, coin: CoinModel(id: UUID(), name: "Ethereum", symbol: "ETH", value: 10545.25, percentage: 49, icon: "e.circle", amountOwned: 0), amountInBRL: "1200,00") {
        // noop
    }
}


