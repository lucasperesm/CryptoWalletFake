import Foundation

class BinanceWebSocketManager {

    private var webSocketTask: URLSessionWebSocketTask?
    
    var onPriceUpdate: ((Double) -> Void)?
    var onError: ((String) -> Void)?

    func connect(symbol: String = "btcusdt") {

        let url = URL(string: "wss://stream.binance.com:9443/ws/\(symbol)@ticker")!
        
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()

        receive()
    }

    private func receive() {
        webSocketTask?.receive { [weak self] result in
            switch result {

            case .failure(let error):
                print("Erro:", error)
                DispatchQueue.main.async {
                    self?.onError?(error.localizedDescription)
                }
                return // para o loop de recepção

            case .success(let message):
                switch message {

                case .string(let text):
                    self?.handleMessage(text)

                case .data(let data):
                    self?.handleData(data)

                @unknown default:
                    break
                }
            }

            // continua ouvindo
            self?.receive()
        }
    }

    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        parseData(data)
    }

    private func handleData(_ data: Data) {
        parseData(data)
    }

    private func parseData(_ data: Data) {
        do {
            let trade = try JSONDecoder().decode(BinanceTrade.self, from: data)
            
            if let price = Double(trade.price) {
                DispatchQueue.main.async {
                    self.onPriceUpdate?(price)
                }
            }

        } catch {
            print("Erro parse JSON:", error)
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}
