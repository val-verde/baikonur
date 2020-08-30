import XCTest
import XCTVapor
import class Foundation.Bundle

final class baikonurTests: XCTestCase {
  func testExample() throws {
    let app = Application(Environment(
      name: "testing",
      arguments: ["vapor"]
    ))

    defer { app.shutdown() }

    app.get { req in
        "Hello, world!"
    }

    try app.start()

    let res = try app.client.get("http://localhost:8080/").wait()
    XCTAssertEqual(res.body?.string, "Hello, world!")
  }

  static var allTests = [
      ("testExample", testExample),
  ]
}
