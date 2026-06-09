import SwiftUI

struct LogoCriptoWallet: View {
    var size: CGFloat = 100
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                // Wallet principal (carteira)
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.1))
                    .stroke(Color.white, lineWidth: 2.5)
                    .frame(width: size * 0.8, height: size * 0.55)
                
                // Aba da carteira
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.15))
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: size * 0.65, height: size * 0.3)
                    .offset(y: -size * 0.06)
                
                // Aba da carteira
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.15))
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: size * 0.65, height: size * 0.3)
                    .offset(y: -size * 0.00)
                
                // Aba da carteira
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.15))
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: size * 0.65, height: size * 0.25)
                    .offset(y: -size * -0.04)
                
                RoundedRectangle(cornerRadius: 0)
                    .fill(
                        Color(red: 99 / 255, green: 57 / 255, blue: 249 / 255)
                            .opacity(1)
                    )
                    .frame(width: size * 0.77, height: size * 0.2)
                    .offset(y: -size * -0.08)
                
                
                
                // Coin (moeda) com brilho
                
                
                
                
                // Moeda stroke
                Circle()
                    .stroke(Color.white, lineWidth: 2.5)
                    .glassEffect()
                    .frame(width: size * 0.25, height: size * 0.25)
                    .offset(x: size * 0.0, y: size * 0.08)
                
                
                // Bitcoin symbol na moeda
                Text("₿")
                    .font(.system(size: size * 0.18, weight: .bold))
                    .foregroundColor(Color(red: 99 / 255, green: 57 / 255, blue: 249 / 255))
                    .offset(x: size * 0.0, y: size * 0.08)
            }
            .frame(width: size, height: size * 0.75)
            
            // Texto CryptoWallet
            Text("CryptoWallet")
                .font(.system(size: size * 0.22,))
                .foregroundColor(.white)
                .tracking(4)
        }
    }
}

#Preview {
    LogoCriptoWallet(size: 120)
        .background(Color.black)
}
