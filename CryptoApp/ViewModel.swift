import Foundation
import SwiftData

extension ContentView {
    @Observable
    class ViewModel {
        var modelContext: ModelContext
        var coins = [Coin]()

        init(modelContext: ModelContext) {
            self.modelContext = modelContext
            fetchData()
        }
        
        func fetchFromAPI() async {
            let header = [
                "Content-Type": "application/json",
                "x-cg-demo-api-key": "CG-z4cf5L9ZFUUMj7HDPoG5DNG6"
            ] as Dictionary<String, String>
            var request = URLRequest(url: URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd")!)
            request.allHTTPHeaderFields = header
            request.httpMethod = "GET"
            let session = URLSession.shared
            do {
                let (data, _) = try await session.data(for: request)
                let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
                for c in json! {
                    self.modelContext.insert(Coin(id: c["id"] as! String, symbol: c["symbol"] as! String, name: c["name"] as! String, image: c["image"] as! String, market_cap_rank: c["market_cap_rank"] as! Int, current_price: c["current_price"] as! Double, market_cap: c["market_cap"] as! Double, chartData: []))
                }
            } catch {
                print("error")
            }
            fetchData()
        }

        func fetchData() {
            do {
                let descriptor = FetchDescriptor<Coin>(sortBy: [SortDescriptor(\.market_cap_rank)])
                coins = try modelContext.fetch(descriptor).filter { $0.expire > Date.now }
            } catch {
                print("Fetch failed")
            }
        }
        
        func fetchPriceChart(coin: Coin) async throws -> [CoinChart] {
            var chartData: [CoinChart] = []
            let header = [
                "Content-Type": "application/json",
                "x-cg-demo-api-key": "CG-z4cf5L9ZFUUMj7HDPoG5DNG6"
            ] as Dictionary<String, String>
            var request = URLRequest(url: URL(string: "https://api.coingecko.com/api/v3/coins/\(coin.id)/market_chart?vs_currency=usd&days=30&interval=daily")!)
            request.allHTTPHeaderFields = header
            request.httpMethod = "GET"
            let session = URLSession.shared
            let (data, _) = try await session.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? Dictionary<String, [[Double]]>
            for c in json!["prices"]! {
                chartData.append(CoinChart(date: Int(c[0]) / 1000, price: c[1]))
            }
            return chartData
        }
    }
}
