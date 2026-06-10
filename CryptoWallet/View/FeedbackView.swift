

import Foundation
import SwiftUI

struct FeedbackView: View {

    @Environment(\.dismiss) private var dismiss

    let mode: SellOrBuyView.Mode

    let coin: CoinModel?

    let amountInBRL: String

    let onReturn: () -> Void

    @State private var showConfetti = false

    @State private var pulseAnimation = false

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

        if mode == .buy {

            return "You successfully bought \(coinName)"

        } else {

            return "You successfully sold \(coinName)"

        }

    }

    private var amountText: String {
        guard !amountInBRL.isEmpty else { return "" }
        let crypto = CoinCalculator.cryptoAmount(fromBRL: amountInBRL, coinValue: coin?.value ?? 1)
        return "R$ \(amountInBRL) • \(crypto) \(coin?.symbol ?? "")"
    }

    var body: some View {

        ZStack {

            // Background

            AppBackground {

                Color.clear

            }

            VStack(spacing: 28) {

                Spacer()

                // Card com confetes

                ZStack {

                    // Card background

                    VStack(spacing: 20) {

                        // Animated Check Circle

                        ZStack {

                            Circle()

                                .fill(

                                    LinearGradient(

                                        colors: [

                                            Color(red: 99/255, green: 57/255, blue: 249/255).opacity(0.25),

                                            Color(red: 88/255, green: 52/255, blue: 190/255).opacity(0.15)

                                        ],

                                        startPoint: .topLeading,

                                        endPoint: .bottomTrailing

                                    )

                                )

                                .frame(width: 100, height: 100)

                                .scaleEffect(pulseAnimation ? 1.1 : 1.0)

                                .opacity(pulseAnimation ? 0.8 : 1.0)

                            Image(systemName: "checkmark.circle.fill")

                                .font(.system(size: 52))

                                .foregroundColor(Color(red: 52/255, green: 199/255, blue: 89/255))

                                .scaleEffect(pulseAnimation ? 1.2 : 1.0)

                        }

                        VStack(spacing: 8) {

                            Text(titleText)

                                .font(.system(size: 24, weight: .bold))

                                .foregroundColor(.white)

                                .multilineTextAlignment(.center)

                            Text(subtitleText)

                                .font(.system(size: 14, weight: .medium))

                                .foregroundColor(.white.opacity(0.7))

                                .multilineTextAlignment(.center)

                        }

                        // Botão do valor - mesma cor do Back to Wallet

                        Text(amountText)

                            .font(.system(size: 16, weight: .semibold))

                            .foregroundColor(.white)

                            .padding(.vertical, 12)

                            .padding(.horizontal, 24)

                            .background(

                                Capsule()

                                    .fill(Color.white.opacity(0.15))

                            )

                            .overlay(

                                Capsule()

                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)

                            )

                    }

                    .padding(.vertical, 32)

                    .padding(.horizontal, 24)

                    .frame(maxWidth: .infinity)

                    .background(

                        RoundedRectangle(cornerRadius: 32)

                            .fill(

                                LinearGradient(

                                    colors: [

                                        Color(red: 99/255, green: 57/255, blue: 249/255).opacity(0.12),

                                        Color(red: 88/255, green: 52/255, blue: 190/255).opacity(0.08)

                                    ],

                                    startPoint: .topLeading,

                                    endPoint: .bottomTrailing

                                )

                            )

                            .overlay(

                                RoundedRectangle(cornerRadius: 32)

                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)

                            )

                    )

                    .padding(.horizontal, 24)

                    // Confetes

                    if showConfetti {

                        ConfettiView()

                            .allowsHitTesting(false)

                    }

                }

                Spacer()

                // Botão Back to Wallet

                PrimaryButton(title: "Back to Wallet", action: {

                    onReturn()

                    dismiss()

                })

                .padding(.horizontal, 24)

                .padding(.bottom, 40)

            }

        }

        .ignoresSafeArea()

        .onAppear {

            withAnimation(.easeInOut(duration: 0.6).repeatCount(2, autoreverses: true)) {

                pulseAnimation = true

            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

                showConfetti = true

                // Remove confetes após 4 segundos

                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {

                    showConfetti = false

                }

            }

        }

    }

}

// MARK: - Confetti View

struct ConfettiView: View {

    let screenHeight = UIScreen.main.bounds.height

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                ForEach(0..<80, id: \.self) { index in

                    ConfettiPiece(

                        color: randomConfettiColor(),

                        size: CGSize(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 4...8)),

                        startX: CGFloat.random(in: 0...geometry.size.width),

                        startY: -20,

                        endY: screenHeight + 100,

                        duration: Double.random(in: 2.5...4.5),

                        delay: Double.random(in: 0...0.6)

                    )

                }

            }

        }

        .ignoresSafeArea()

    }

    private func randomConfettiColor() -> Color {

        let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan, .mint, .white]

        return colors.randomElement() ?? .yellow

    }

}

// MARK: - Confetti Piece

struct ConfettiPiece: View {

    let color: Color

    let size: CGSize

    let startX: CGFloat

    let startY: CGFloat

    let endY: CGFloat

    let duration: Double

    let delay: Double

    @State private var currentY: CGFloat = -20

    @State private var currentRotation: Double = 0

    @State private var currentX: CGFloat = 0

    var body: some View {

        Rectangle()

            .fill(color)

            .frame(width: size.width, height: size.height)

            .rotationEffect(.degrees(currentRotation))

            .position(x: currentX, y: currentY)

            .onAppear {

                currentX = startX

                withAnimation(

                    .linear(duration: duration)

                    .delay(delay)

                ) {

                    currentY = endY

                    currentRotation = Double.random(in: 360...1080)

                }

            }

    }

}

// MARK: - Preview

#Preview {

    FeedbackView(

        mode: .buy,

        coin: CoinModel(

            id: UUID(),

            name: "Bitcoin",

            symbol: "BTC",

            value: 250000,

            percentage: 2.5,

            icon: "b.circle",

            amountOwned: 0

        ),

        amountInBRL: "14,00",

        onReturn: {}

    )

}
 

