import Foundation
import CoreData
import SwiftUI
import Combine
 
class WalletViewModel: ObservableObject {
 
    private struct BinanceTicker24h: Decodable {
        let symbol: String
        let lastPrice: String
        let priceChangePercent: String
    }
   
    private let context: NSManagedObjectContext
    private var currentUser: User?
   
    @Published var coins: [CoinModel] = []
    @Published var fiatBalance: Double = 1074.32
 
    private let defaultFiatBalance: Double = 1074.32
   
    // MARK: - Propriedades Calculadas para a View
   
    var totalBalance: Double {
        coins.reduce(0) { $0 + ($1.value * $1.amountOwned) }
    }
   
    var profit: Double {
        // Lucro/prejuízo diário ponderado pela variação real de cada moeda (24h Binance).
        coins.reduce(0) { partial, coin in
            let holdingValue = coin.value * coin.amountOwned
            let coinDelta = holdingValue * (coin.percentage / 100.0)
            return partial + coinDelta
        }
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
 
        ensureFiatBalanceExists()
 
        repairOrphanCoinsForCurrentUser()
        deduplicateCoinsForCurrentUser()
       
        fetchCoinsAndMarketData()
    }
 
    private func ensureFiatBalanceExists() {
        guard let currentUser else { return }
 
        guard supportsFiatBalanceField(for: currentUser) else {
            fiatBalance = defaultFiatBalance
            return
        }
 
        if currentUser.value(forKey: "fiatBalance") == nil {
            currentUser.setValue(defaultFiatBalance, forKey: "fiatBalance")
            do {
                try context.save()
            } catch {
                print("Erro ao inicializar saldo fiat: \(error)")
            }
        }
 
        fiatBalance = (currentUser.value(forKey: "fiatBalance") as? Double) ?? defaultFiatBalance
    }
 
    private func supportsFiatBalanceField(for user: User) -> Bool {
        user.entity.attributesByName["fiatBalance"] != nil
    }
 
    private func supportsMultiCoinRelationship(for user: User) -> Bool {
        user.entity.relationshipsByName["coins"]?.isToMany ?? true
    }
 
    private var isUsingRelationshipFallback: Bool {
        guard let currentUser else { return false }
        return !supportsMultiCoinRelationship(for: currentUser)
    }
 
    private func readFiatBalance(for user: User) -> Double {
        guard supportsFiatBalanceField(for: user) else {
            return fiatBalance
        }
        return (user.value(forKey: "fiatBalance") as? Double) ?? defaultFiatBalance
    }
 
    private func writeFiatBalance(_ value: Double, for user: User) {
        guard supportsFiatBalanceField(for: user) else {
            fiatBalance = value
            return
        }
        user.setValue(value, forKey: "fiatBalance")
        fiatBalance = value
    }
 
    private func repairOrphanCoinsForCurrentUser() {
        guard let currentUser else { return }
 
        if isUsingRelationshipFallback {
            return
        }
 
        let orphanRequest = NSFetchRequest<NSManagedObject>(entityName: "Coin")
        orphanRequest.predicate = NSPredicate(format: "user == nil")
 
        let ownedRequest = NSFetchRequest<NSManagedObject>(entityName: "Coin")
        ownedRequest.predicate = NSPredicate(format: "user == %@", currentUser)
 
        do {
            let ownedCoins = try context.fetch(ownedRequest)
            var ownedSymbols = Set(ownedCoins.compactMap { $0.value(forKey: "symbol") as? String })
 
            let orphanCoins = try context.fetch(orphanRequest)
            guard !orphanCoins.isEmpty else { return }
 
            for coin in orphanCoins {
                let symbol = (coin.value(forKey: "symbol") as? String) ?? ""
                if !ownedSymbols.contains(symbol) {
                    coin.setValue(currentUser, forKey: "user")
                    if !symbol.isEmpty {
                        ownedSymbols.insert(symbol)
                    }
                }
            }
 
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("Erro ao recuperar moedas orfas: \(error)")
        }
    }
 
    private func deduplicateCoinsForCurrentUser() {
        guard let currentUser else { return }
 
        let request = NSFetchRequest<NSManagedObject>(entityName: "Coin")
        if isUsingRelationshipFallback {
            request.predicate = NSPredicate(format: "user == %@ OR user == nil", currentUser)
        } else {
            request.predicate = NSPredicate(format: "user == %@", currentUser)
        }
 
        do {
            let allCoins = try context.fetch(request)
            var groupedBySymbol: [String: [NSManagedObject]] = [:]
 
            for coin in allCoins {
                let symbol = ((coin.value(forKey: "symbol") as? String) ?? "").uppercased()
                guard !symbol.isEmpty else { continue }
                groupedBySymbol[symbol, default: []].append(coin)
            }
 
            var hasDeletedDuplicates = false
 
            for (_, coinsForSymbol) in groupedBySymbol where coinsForSymbol.count > 1 {
                let sorted = coinsForSymbol.sorted { lhs, rhs in
                    let lhsAmount = lhs.value(forKey: "amountOwned") as? Double ?? 0
                    let rhsAmount = rhs.value(forKey: "amountOwned") as? Double ?? 0
                    if lhsAmount != rhsAmount {
                        return lhsAmount > rhsAmount
                    }
 
                    let lhsHasUser = lhs.value(forKey: "user") != nil
                    let rhsHasUser = rhs.value(forKey: "user") != nil
                    if lhsHasUser != rhsHasUser {
                        return lhsHasUser
                    }
 
                    return lhs.objectID.uriRepresentation().absoluteString > rhs.objectID.uriRepresentation().absoluteString
                }
 
                for duplicate in sorted.dropFirst() {
                    context.delete(duplicate)
                    hasDeletedDuplicates = true
                }
            }
 
            if hasDeletedDuplicates {
                try context.save()
            }
        } catch {
            print("Erro ao remover moedas duplicadas: \(error)")
        }
    }
   
    // MARK: - Gerenciamento de Dados
   
    // Busca as moedas do usuário no banco
    func fetchCoinsAndMarketData() {
        // Garante que temos um usuário antes de fazer a busca das moedas
        guard let currentUser = currentUser else { return }
 
        deduplicateCoinsForCurrentUser()
 
        fiatBalance = readFiatBalance(for: currentUser)
       
        let request = NSFetchRequest<NSManagedObject>(entityName: "Coin")
        if isUsingRelationshipFallback {
            request.predicate = NSPredicate(format: "user == %@ OR user == nil", currentUser)
        } else {
            request.predicate = NSPredicate(format: "user == %@", currentUser)
        }
       
        do {
            let coreDataCoins = try context.fetch(request)
 
            fetchBinanceMarketData { [weak self] marketPrices in
                guard let self else { return }
 
                var updatedCoins: [CoinModel] = []
 
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
 
                DispatchQueue.main.async {
                    self.coins = updatedCoins
                }
            }
 
        } catch {
            print("Erro ao carregar moedas do Core Data: \(error)")
        }
    }
 
    private func fetchBinanceMarketData(completion: @escaping ([String: (price: Double, change: Double, icon: String)]) -> Void) {
        var marketPrices: [String: (price: Double, change: Double, icon: String)] = [
            "BTC": (65000.0, 0.0, "bitcoinsign.circle"),
            "ETH": (3500.0, 0.0, "e.circle"),
            "BNB": (150.0, 0.0, "b.circle"),
            "USD": (1.0, 0.0, "dollarsign.circle")
        ]
 
        guard let url = URL(string: "https://api.binance.com/api/v3/ticker/24hr") else {
            completion(marketPrices)
            return
        }
 
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data, error == nil else {
                completion(marketPrices)
                return
            }
 
            do {
                let tickers = try JSONDecoder().decode([BinanceTicker24h].self, from: data)
                let wantedSymbols = ["BTCUSDT": "BTC", "ETHUSDT": "ETH", "BNBUSDT": "BNB"]
 
                for ticker in tickers {
                    guard let localSymbol = wantedSymbols[ticker.symbol] else { continue }
                    guard
                        let price = Double(ticker.lastPrice),
                        let change = Double(ticker.priceChangePercent)
                    else { continue }
 
                    let icon: String
                    switch localSymbol {
                    case "BTC": icon = "bitcoinsign.circle"
                    case "ETH": icon = "e.circle"
                    case "BNB": icon = "b.circle"
                    default: icon = "dollarsign.circle"
                    }
 
                    marketPrices[localSymbol] = (price, change, icon)
                }
            } catch {
                print("Erro ao decodificar ticker 24h da Binance: \(error)")
            }
 
            completion(marketPrices)
        }.resume()
    }
   
    // MARK: - Operações do Banco (Ações de Compra e Venda)
   
    // Executa a lógica de compra de uma moeda no Core Data
    func buyCoin(symbol: String, name: String, amountToBuy: Double, amountBRL: Double) -> Bool {
        guard let currentUser = currentUser else {
            print("Erro: Nenhum usuário logado encontrado para realizar a compra.")
            return false
        }
 
        let currentFiat = readFiatBalance(for: currentUser)
        guard amountBRL > 0, currentFiat >= amountBRL else {
            return false
        }
       
        let request = NSFetchRequest<NSManagedObject>(entityName: "Coin")
        if isUsingRelationshipFallback {
            request.predicate = NSPredicate(format: "(user == %@ OR user == nil) AND symbol == %@", currentUser, symbol)
        } else {
            request.predicate = NSPredicate(format: "user == %@ AND symbol == %@", currentUser, symbol)
        }
       
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
                if !isUsingRelationshipFallback {
                    newCoin.setValue(currentUser, forKey: "user")
                }
            }
 
            writeFiatBalance(currentFiat - amountBRL, for: currentUser)
           
            try context.save()
            fetchCoinsAndMarketData()
            return true
           
        } catch {
            print("Erro ao salvar a compra no Core Data: \(error)")
            return false
        }
    }
   
    // Executa a lógica de venda de uma moeda no Core Data
    func sellCoin(symbol: String, amountToSell: Double, amountBRL: Double) -> Bool {
        guard let currentUser = currentUser else {
            print("Erro: Nenhum usuário logado encontrado para realizar a compra.")
            return false
        }
       
        let request = NSFetchRequest<NSManagedObject>(entityName: "Coin")
        if isUsingRelationshipFallback {
            request.predicate = NSPredicate(format: "(user == %@ OR user == nil) AND symbol == %@", currentUser, symbol)
        } else {
            request.predicate = NSPredicate(format: "user == %@ AND symbol == %@", currentUser, symbol)
        }
       
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
 
                let currentFiat = readFiatBalance(for: currentUser)
                writeFiatBalance(currentFiat + max(0, amountBRL), for: currentUser)
               
                try context.save()
                fetchCoinsAndMarketData()
                return true
            }
            return false
        } catch {
            print("Erro ao processar a venda no Core Data: \(error)")
            return false
        }
    }
}
