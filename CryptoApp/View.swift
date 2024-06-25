import SwiftUI
import SwiftData
import Charts

struct ContentView: View {
    @State private var viewModel: ViewModel
    @State private var isPerformingTask = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.searchResults) { coin in
                        NavigationLink(destination: CoinDetail(coin: coin)) {
                            VStack(alignment: .leading) {
                                HStack {
                                    AsyncImage(url: URL(string: coin.image)){ result in
                                        result.image?
                                            .resizable()
                                            .scaledToFill()
                                    }
                                    .frame(width: 25, height: 25)
                                    Text(coin.name).font(.headline)
                                }
                                Text("$" + coin.current_price.clean).font(.title)
                            }
                        }.onAppear() {
                            if coin.chartData1D.isEmpty {
                                Task {
                                    do {
                                        coin.chartData1D = try await viewModel.fetchPriceChart(coin: coin, scale: "1Д")
                                    } catch {
                                        print("Закончился лимит запросов API.")
                                    }
                                }
                            }
                            if coin.chartData7D.isEmpty {
                                Task {
                                    do {
                                        coin.chartData7D = try await viewModel.fetchPriceChart(coin: coin, scale: "7Д")
                                    } catch {
                                        print("Закончился лимит запросов API.")
                                    }
                                }
                            }
                            if coin.chartData1M.isEmpty {
                                Task {
                                    do {
                                        coin.chartData1M = try await viewModel.fetchPriceChart(coin: coin, scale: "1М")
                                    } catch {
                                        print("Закончился лимит запросов API.")
                                    }
                                }
                            }
                            if coin.chartData3M.isEmpty {
                                Task {
                                    do {
                                        coin.chartData3M = try await viewModel.fetchPriceChart(coin: coin, scale: "3М")
                                    } catch {
                                        print("Закончился лимит запросов API.")
                                    }
                                }
                            }
                            if coin.chartData1Y.isEmpty {
                                Task {
                                    do {
                                        coin.chartData1Y = try await viewModel.fetchPriceChart(coin: coin, scale: "1Г")
                                    } catch {
                                        print("Закончился лимит запросов API.")
                                    }
                                }
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem {
                        Button(action: {
                            isPerformingTask = true
                            Task {
                                await viewModel.fetchFromAPI()
                                isPerformingTask = false
                            }
                        }) {
                            Label("Обновить", systemImage: "arrow.clockwise")
                        }
                    }
                }
                .searchable(text: $viewModel.searchText)
                .navigationTitle("Курсы валют")
                if viewModel.coins.isEmpty {
                    Text("Добро пожаловать! Нажмите кнопку \(Image(systemName: "arrow.clockwise")).")
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    init(modelContext: ModelContext) {
        let viewModel = ViewModel(modelContext: modelContext)
        _viewModel = State(initialValue: viewModel)
    }
}

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

extension Double {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

#Preview {
    let container: ModelContainer
    do {
        container = try ModelContainer(for: Coin.self)
    } catch {
        fatalError("Не удалось создать контейнер для Coin.")
    }
    return ContentView(modelContext: container.mainContext)
}
