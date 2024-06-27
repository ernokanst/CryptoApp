import SwiftUI
import Charts

struct CoinDetail: View {
    @State var coin: Coin
    @State private var selectedScale = "1М"
    @State private var selectedChart: [CoinChart]
    let chartScales = ["1Д", "7Д", "1М", "3М", "1Г"]
    
    init(coin: Coin) {
        self.coin = coin
        selectedChart = coin.chartData1M
    }

    var body: some View {
        VStack {
            HStack {
                AsyncImage(url: URL(string: coin.image)){ result in
                    result.image?
                        .resizable()
                        .scaledToFill()
                }
                .frame(width: 50, height: 50)
                Text(coin.name)
                    .font(.largeTitle)
            }
            Chart(selectedChart.sorted(by: { $0.date.compare($1.date) == .orderedAscending }), id: \.date) {
                    LineMark(
                        x: .value("День", $0.date),
                        y: .value("Цена", $0.price)
                    )
                }
            .chartYScale(domain: [(selectedChart.map({ $0.price }).min() ?? 0) * 0.9, (selectedChart.map({ $0.price }).max() ?? 10000) * 1.1])
            Picker("Масштаб", selection: $selectedScale) {
                ForEach(chartScales, id: \.self) {
                    Text($0)
                }
            }.pickerStyle(.segmented).padding(/*@START_MENU_TOKEN@*/.all, 8.0/*@END_MENU_TOKEN@*/)
            .onChange(of: selectedScale) {
                switch selectedScale {
                case "1Д":
                    selectedChart = coin.chartData1D
                case "7Д":
                    selectedChart = coin.chartData7D
                case "1М":
                    selectedChart = coin.chartData1M
                case "3М":
                    selectedChart = coin.chartData3M
                case "1Г":
                    selectedChart = coin.chartData1Y
                default:
                    selectedChart = coin.chartData1M
                }
            }
            List {
                HStack {
                    Text("Код:")
                    Spacer()
                    Text(coin.symbol.uppercased())
                }
                HStack {
                    Text("Текущая цена:")
                    Spacer()
                    Text("$" + coin.current_price.clean)
                }
                HStack {
                    Text("Рыночная капитализация:")
                    Spacer()
                    Text("$" + coin.market_cap.clean)
                }
            }
        }
    }
}
