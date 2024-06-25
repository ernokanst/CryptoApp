import XCTest
import SwiftData
@testable import CryptoApp

final class CryptoAppTests: XCTestCase {
    
    var container: ModelContainer!
    var viewModel: ContentView.ViewModel!

    @MainActor override func setUpWithError() throws {
        try super.setUpWithError()
        container = try ModelContainer(for: Coin.self)
        viewModel = ContentView.ViewModel(modelContext: container.mainContext)
    }

    override func tearDownWithError() throws {
        container = nil
        viewModel = nil
        try super.tearDownWithError()
    }

    func testFetchFromAPI() async throws {
        await viewModel.fetchFromAPI()
        XCTAssertFalse(viewModel.coins.isEmpty)
        XCTAssertGreaterThanOrEqual(viewModel.coins.count, 95)
        XCTAssertEqual(viewModel.coins[0].market_cap_rank, 1)
        XCTAssertEqual(viewModel.coins[41].market_cap_rank, 42)
        XCTAssertEqual(viewModel.coins[0].id, "bitcoin")
    }
    
    func testFetchPriceChart() async throws {
        await viewModel.fetchFromAPI()
        let btc = viewModel.coins[0]
        let charData = try await viewModel.fetchPriceChart(coin: btc, scale: "1М")
        XCTAssertFalse(charData.isEmpty)
        XCTAssertEqual(charData.count, 31)
        let calendar = Calendar(identifier: .gregorian)
        for d in charData {
            XCTAssertGreaterThan(d.date, calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 0, minute: 0, second: 0))!)
            XCTAssertLessThan(d.date, calendar.date(from: DateComponents(year: 2025, month: 1, day: 1, hour: 0, minute: 0, second: 0))!)
            XCTAssertGreaterThanOrEqual(d.price, 0)
        }
    }
    
    func testSearch() async throws {
        await viewModel.fetchFromAPI()
        XCTAssertFalse(viewModel.coins.isEmpty)
        viewModel.searchText = ""
        XCTAssertEqual(viewModel.coins, viewModel.searchResults)
        viewModel.searchText = "doge"
        XCTAssertFalse(viewModel.searchResults.isEmpty)
        XCTAssertEqual(viewModel.searchResults.count, 1)
        XCTAssertEqual(viewModel.searchResults[0].name, "Dogecoin")
    }

    func testAPIPerformance() async throws {
        self.measure {
            let exp = expectation(description: "Данные получены")
            Task {
                await viewModel.fetchFromAPI()
                exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
        }
    }
    
    func testChartPerformance1D() async throws {
        self.measure {
            let exp = expectation(description: "Данные получены")
            Task {
                await viewModel.fetchFromAPI()
                let btc = viewModel.coins[0]
                _ = try await viewModel.fetchPriceChart(coin: btc, scale: "1Д")
                exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
        }
    }
    
    func testChartPerformance7D() async throws {
        self.measure {
            let exp = expectation(description: "Данные получены")
            Task {
                await viewModel.fetchFromAPI()
                let btc = viewModel.coins[0]
                _ = try await viewModel.fetchPriceChart(coin: btc, scale: "7Д")
                exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
        }
    }
    
    func testChartPerformance1M() async throws {
        self.measure {
            let exp = expectation(description: "Данные получены")
            Task {
                await viewModel.fetchFromAPI()
                let btc = viewModel.coins[0]
                _ = try await viewModel.fetchPriceChart(coin: btc, scale: "1М")
                exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
        }
    }
    
    func testChartPerformance3M() async throws {
        self.measure {
            let exp = expectation(description: "Данные получены")
            Task {
                await viewModel.fetchFromAPI()
                let btc = viewModel.coins[0]
                _ = try await viewModel.fetchPriceChart(coin: btc, scale: "3М")
                exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
        }
    }
    
    func testChartPerformance1Y() async throws {
        self.measure {
            let exp = expectation(description: "Данные получены")
            Task {
                await viewModel.fetchFromAPI()
                let btc = viewModel.coins[0]
                _ = try await viewModel.fetchPriceChart(coin: btc, scale: "1Г")
                exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
        }
    }
}
