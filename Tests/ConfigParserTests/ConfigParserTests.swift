import XCTest
@testable import ConfigParser

final class ConfigParserTests: XCTestCase {
    func testParseString() {
        var contents = """
        global_opt = 10

        ; Comment type 1
        # Comment type 2

        [DEFAULTS]
        default_opt = default

        [section title]
        section_opt = hello

        [section_title_2]
        new_section_opt = world

        [trimming]
        trim_section =   This should trim the trailing spaces   

        [last]
        last_section = "This is a quoted value"
        """

        let config: Config
        do {
            config = try ConfigParser.parse(&contents)
        } catch {
            XCTFail("Failed to parse string with error: \(error)")
            return
        }

        let sections = Array(config.sections())
        XCTAssertTrue(sections.contains("section title"))
        XCTAssertTrue(sections.contains("section_title_2"))
        XCTAssertTrue(sections.contains("trimming"))
        XCTAssertTrue(sections.contains("last"))
        XCTAssertEqual(config.globals, ["global_opt": "10"])
        XCTAssertEqual(config["section title"], ["section_opt": "hello"])
        XCTAssertEqual(config["trimming"]!["trim_section"], "This should trim the trailing spaces")
        XCTAssertEqual(config["last"]!["last_section"], "This is a quoted value")
        XCTAssertEqual(config["last", "default_opt"], "default")
    }

    static var allTests = [
        ("testParseString", testParseString),
    ]
}
