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
        XCTAssertEqual(viewModel.coins.count, 100)
        XCTAssertEqual(viewModel.coins[0].market_cap_rank, 1)
        XCTAssertEqual(viewModel.coins[99].market_cap_rank, 100)
        XCTAssertEqual(viewModel.coins[0].id, "bitcoin")
    }
    
    func testFetchPriceChart() async throws {
        await viewModel.fetchFromAPI()
        var btc = viewModel.coins[0]
        var charData = try await viewModel.fetchPriceChart(coin: btc)
        XCTAssertFalse(charData.isEmpty)
        XCTAssertEqual(charData.count, 31)
        var calendar = Calendar(identifier: .gregorian)
        for d in charData {
            XCTAssertGreaterThan(d.date, calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 0, minute: 0, second: 0))!)
            XCTAssertLessThan(d.date, calendar.date(from: DateComponents(year: 2025, month: 1, day: 1, hour: 0, minute: 0, second: 0))!)
            XCTAssertGreaterThanOrEqual(d.price, 0)
        }
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
    
    func testChartPerformance() async throws {
        self.measure {
            let exp = expectation(description: "Данные получены")
            Task {
                await viewModel.fetchFromAPI()
                var btc = viewModel.coins[0]
                var charData = try await viewModel.fetchPriceChart(coin: btc)
                exp.fulfill()
            }
            wait(for: [exp], timeout: 10.0)
        }
    }

}
