import SwiftUI
import SwiftData

struct CoinView: View {
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

#Preview {
    let container: ModelContainer
    do {
        container = try ModelContainer(for: Coin.self)
    } catch {
        fatalError("Не удалось создать контейнер для Coin.")
    }
    return CoinView(modelContext: container.mainContext)
}
