import Foundation
import SwiftData

@Model
class CoinChart {
    var date: Date
    var price: Double

    init(date: Int, price: Double) {
        self.date = Date(timeIntervalSince1970: TimeInterval(date))
        self.price = price
    }
}
