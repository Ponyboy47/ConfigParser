import XCTest
@testable import ConfigParser

final class ConfigParserTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ConfigParser().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
