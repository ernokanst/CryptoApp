import Foundation
import SwiftData

@Model
final class Coin {
    @Attribute(.unique) var id: String
    var symbol: String
    var name: String
    var image: String
    var market_cap_rank: Int
    var current_price: Double
    var market_cap: Double
    var chartData: [CoinChart]
    var expire: Date
    
    init(id: String, symbol: String, name: String, image: String, market_cap_rank: Int, current_price: Double, market_cap: Double, chartData: [CoinChart]) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.image = image
        self.market_cap_rank = market_cap_rank
        self.current_price = current_price
        self.market_cap = market_cap
        self.chartData = chartData
        self.expire = Date.now + 15 * 60
    }
}

@Model
class CoinChart {
    var date: Date
    var price: Double

    init(date: Int, price: Double) {
        self.date = Date(timeIntervalSince1970: TimeInterval(date))
        self.price = price
    }
}
