import SwiftUI

struct CoinCard: View {
    let coin: CoinModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Image(systemName: coin.icon)
                    .frame(width: 24)
                
                Text(coin.name)
                    .font(.system(size: 14, weight: .semibold))
                
                Spacer()
                
                Text("\(Int(coin.percentage))%")
                    .foregroundColor(.green)
            }
            
            Text("$\(coin.value, specifier: "%.2f")")
                .font(.system(size: 18, weight: .semibold))
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 90)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15))
        )
        .foregroundColor(.white)
    }
}

