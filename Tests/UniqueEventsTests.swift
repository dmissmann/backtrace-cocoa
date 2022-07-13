import XCTest

import Nimble
import Quick
@testable import Backtrace

final class UniqueEventsTests: QuickSpec {

    override func spec() {
        describe("Backtrace metrics unique events") {
            let urlSession = URLSessionMock()
            let credentials =
                BacktraceCredentials(endpoint: URL(string: "https://yourteam.backtrace.io")!, token: "")
            var backtraceApi = BacktraceApi(credentials: credentials, session: urlSession, reportsPerMin: 30)
            let delegate = BacktraceMetricsDelegateSpy()

            var metrics = BacktraceMetrics(api: backtraceApi)

            beforeEach {
                delegate.clear()
                backtraceApi = BacktraceApi(credentials: credentials, session: urlSession, reportsPerMin: 30)
                metrics = BacktraceMetrics(api: backtraceApi)

                metrics.uniqueEventsDelegate = delegate
            }

            afterEach {
                MetricsInfo.disableMetrics()
            }

            it("sends unique events startup event") {
                urlSession.response = MockOkResponse()
                metrics.enable(settings: BacktraceMetricsSettings())

                expect { delegate.calledWillSendRequest }.toEventually(beTrue(), timeout: .seconds(11), pollInterval: .seconds(1))
                expect { delegate.calledServerDidRespond }.toEventually(beTrue(), timeout: .seconds(11), pollInterval: .seconds(1))
                expect { delegate.calledConnectionDidFail }.toEventually(beFalse(), timeout: .seconds(11), pollInterval: .seconds(1))
            }
        }
    }
}
