import Foundation
import CoreData
import SwiftUI
import Combine

class WalletViewModel: ObservableObject {
    
    private let context: NSManagedObjectContext
    private var currentUser: User?
    
    @Published var coins: [CoinModel] = []
    
    // MARK: - Propriedades Calculadas para a View
    
    var totalBalance: Double {
        coins.reduce(0) { $0 + ($1.value * $1.amountOwned) }
    }
    
    var profit: Double {
        // TODO: Mock provisório de lucro (simula ganhos de 5.42% sobre o total)
        // Quando criar o histórico de transações, poderá calcular o lucro real aqui
        return totalBalance * 0.0542
    }
    
    var profitPercentage: Double {
        let balance = totalBalance
        return balance > 0 ? (profit / balance) * 100 : 0.0
    }
    
    var profitColor: Color {
        return profit >= 0 ? Color.green : Color.red
    }
    
    var profitPrefix: String {
        return profit >= 0 ? "+" : ""
    }
    

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        
        let request = NSFetchRequest<User>(entityName: "User")
        request.fetchLimit = 1
        
        do {
            let users = try context.fetch(request)
            if let loggedUser = users.first {
                self.currentUser = loggedUser
            } else {
                self.currentUser = User(context: context)
            }
        } catch {
            print("Erro ao recuperar o usuário logado: \(error)")
            self.currentUser = User(context: context)
        }
        
        fetchCoinsAndMarketData()
    }
    
    // MARK: - Gerenciamento de Dados
    
    // Busca as moedas do usuário no banco
    func fetchCoinsAndMarketData() {
        // Garante que temos um usuário antes de fazer a busca das moedas
        guard let currentUser = currentUser else { return }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "Coin")
        request.predicate = NSPredicate(format: "user == %@", currentUser)
        
        do {
            let coreDataCoins = try context.fetch(request)
            
            // TODO: Mock de dados de mercado (Simulando o retorno que virá da API da Binance)
            let marketPrices: [String: (price: Double, change: Double, icon: String)] = [
                "BTC": (65000.0, 6.2, "bitcoinsign.circle"),
                "ETH": (3500.0, 4.8, "e.circle"),
                "BNB": (150.0, 12.5, "b.circle"),
                "USD": (0.50, -2.1, "dollarsign.circle")
            ]
            
            var updatedCoins: [CoinModel] = []
            
            // Mapeia e adiciona as moedas que o usuário já comprou (salvas no banco)
            for entity in coreDataCoins {
                let symbol = entity.value(forKey: "symbol") as? String ?? ""
                let name = entity.value(forKey: "name") as? String ?? ""
                let amount = entity.value(forKey: "amountOwned") as? Double ?? 0.0
                let id = entity.value(forKey: "id") as? UUID ?? UUID()
                
                let market = marketPrices[symbol] ?? (0.0, 0.0, "dollarsign.circle")
                
                let coin = CoinModel(
                    id: id,
                    name: name,
                    symbol: symbol,
                    value: market.price,
                    percentage: market.change,
                    icon: market.icon,
                    amountOwned: amount
                )
                updatedCoins.append(coin)
            }
            
            // Adiciona o restante das moedas globais do mercado que ele não possui
            for (symbol, market) in marketPrices {
                if !updatedCoins.contains(where: { $0.symbol == symbol }) {
                    let newCoin = CoinModel(
                        id: UUID(),
                        name: symbol == "BTC" ? "Bitcoin" : symbol == "ETH" ? "Ethereum" : symbol == "BNB" ? "Binance Coin" : symbol == "USD" ? "Dollar" : "",
                        symbol: symbol,
                        value: market.price,
                        percentage: market.change,
                        icon: market.icon,
                        amountOwned: 0.0
                    )
                    updatedCoins.append(newCoin)
                }
            }
            
            // Garante a atualização da interface na Main Thread
            DispatchQueue.main.async {
                self.coins = updatedCoins
            }
            
        } catch {
            print("Erro ao carregar moedas do Core Data: \(error)")
        }
    }
    
    // MARK: - Operações do Banco (Ações de Compra e Venda)
    
    // Executa a lógica de compra de uma moeda no Core Data
    func buyCoin(symbol: String, name: String, amountToBuy: Double) {
        guard let currentUser = currentUser else {
            print("Erro: Nenhum usuário logado encontrado para realizar a compra.")
            return
        }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "Coin")
        request.predicate = NSPredicate(format: "user == %@ AND symbol == %@", currentUser, symbol)
        
        do {
            let results = try context.fetch(request)
            
            if let existingCoin = results.first {
                // Se o usuário já tem essa moeda, incrementa a quantidade
                let currentAmount = existingCoin.value(forKey: "amountOwned") as? Double ?? 0.0
                existingCoin.setValue(currentAmount + amountToBuy, forKey: "amountOwned")
            } else {
                // Se é uma moeda nova, cria um registro do zero vinculado ao usuário
                let newCoin = NSEntityDescription.insertNewObject(forEntityName: "Coin", into: context)
                newCoin.setValue(UUID(), forKey: "id")
                newCoin.setValue(name, forKey: "name")
                newCoin.setValue(symbol, forKey: "symbol")
                newCoin.setValue(amountToBuy, forKey: "amountOwned")
                newCoin.setValue(currentUser, forKey: "user")
            }
            
            try context.save()
            fetchCoinsAndMarketData()
            
        } catch {
            print("Erro ao salvar a compra no Core Data: \(error)")
        }
    }
    
    // Executa a lógica de venda de uma moeda no Core Data
    func sellCoin(symbol: String, amountToSell: Double) {
        guard let currentUser = currentUser else {
            print("Erro: Nenhum usuário logado encontrado para realizar a compra.")
            return
        }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "Coin")
        request.predicate = NSPredicate(format: "user == %@ AND symbol == %@", currentUser, symbol)
        
        do {
            let results = try context.fetch(request)
            
            if let existingCoin = results.first {
                let currentAmount = existingCoin.value(forKey: "amountOwned") as? Double ?? 0.0
                let newAmount = currentAmount - amountToSell
                
                if newAmount <= 0 {
                    context.delete(existingCoin)
                } else {
                    existingCoin.setValue(newAmount, forKey: "amountOwned")
                }
                
                try context.save()
                fetchCoinsAndMarketData()
            }
        } catch {
            print("Erro ao processar a venda no Core Data: \(error)")
        }
    }
}
