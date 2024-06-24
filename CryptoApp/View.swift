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
                    ForEach(viewModel.coins) { coin in
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
                            if coin.chartData.isEmpty {
                                Task {
                                    do {
                                        coin.chartData = try await viewModel.fetchPriceChart(coin: coin)
                                    } catch {
                                        print("error")
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
    var coin: Coin

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
            Chart(coin.chartData.sorted(by: { $0.date.compare($1.date) == .orderedAscending }), id: \.date) {
                    LineMark(
                        x: .value("День", $0.date),
                        y: .value("Цена", $0.price)
                    )
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
        fatalError("Failed to create ModelContainer for Coin.")
    }
    return ContentView(modelContext: container.mainContext)
}
