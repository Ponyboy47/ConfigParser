import XCTest
@testable import ConfigParser

final class ConfigParserTests: XCTestCase {
    func testParseString() {
        let contents = """
        global_opt = 10
        global_opt1 = 11

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
            config = try ConfigParser.parse(contents)
        } catch {
            XCTFail("Failed to parse string with error: \(error)")
            return
        }

        let sections = Array(config.sections)
        XCTAssertTrue(sections.contains("section title"))
        XCTAssertTrue(sections.contains("section_title_2"))
        XCTAssertTrue(sections.contains("trimming"))
        XCTAssertTrue(sections.contains("last"))
        XCTAssertEqual(config.globals, ["global_opt": "10", "global_opt1": "11"])
        XCTAssertEqual(config["section title"], ["section_opt": "hello"])
        XCTAssertEqual(config["trimming"]!["trim_section"], "This should trim the trailing spaces")
        XCTAssertEqual(config["last"]!["last_section"], "This is a quoted value")
        XCTAssertEqual(config[section: "last", key: "default_opt"], "default")
    }

    func testParseTypes() {
        let contents = """
        str = this is a string
        bool1 = true
        bool2 = 1
        bool3 = on
        bool4 = yes
        bool5 = false
        bool6 = 0
        bool7 = off
        bool8 = no
        int = -123
        uint = 123
        decimal = 12.34
        array1 = this, is, an, array
        array2 = true,false,on,off
        array3 = 1, 2, 3, 4
        array4 = 1.2,3.4,5.6,7.8
        """

        let config: Config
        do {
            config = try ConfigParser.parse(contents)
        } catch {
            XCTFail("Failed to parse string with error: \(error)")
            return
        }

        XCTAssertEqual(config[section: "GLOBALS", key: "str"], "this is a string")
        XCTAssertEqual(config.globals["str"], "this is a string")
        XCTAssertTrue(config.globals["bool1"]!)
        XCTAssertTrue(config.globals["bool2"]!)
        XCTAssertTrue(config.globals["bool3"]!)
        XCTAssertTrue(config.globals["bool4"]!)
        XCTAssertFalse(config.globals["bool5"]!)
        XCTAssertFalse(config[section: "GLOBALS", key: "bool6"]!)
        XCTAssertFalse(config.globals["bool7"]!)
        XCTAssertFalse(config.globals["bool8"]!)
        XCTAssertEqual(config.globals["int"]!, -123)
        XCTAssertEqual(config.globals["uint"]!, UInt(123))
        XCTAssertEqual(config.globals["decimal"]!, 12.34)
        XCTAssertEqual(config.globals["array1"]!, ["this", "is", "an", "array"])
        XCTAssertEqual(config.globals.get(key: "array2")!, [true, false, true, false])
        XCTAssertEqual(config.globals.get(key: "array3")!, [1, 2, 3, 4])
        XCTAssertEqual(config.globals.get(key: "array4")!, [1.2, 3.4, 5.6, 7.8])
    }

    func testSubscripts() {
        let contents = """
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

        var config: Config
        do {
            config = try ConfigParser.parse(contents)
        } catch {
            XCTFail("Failed to parse string with error: \(error)")
            return
        }

        XCTAssertEqual(config[section: "section title", key: "section_opt"], "hello")
        config[section: "section title", key: "section_opt"] = "world"
        XCTAssertEqual(config[section: "section title", key: "section_opt"], "world")
    }

    func testGenerate() {
        let contents = """
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

        let config1: Config
        do {
            config1 = try ConfigParser.parse(contents)
        } catch {
            XCTFail("Failed to parse string with error: \(error)")
            return
        }

        let generated = config1.output()

        let config2: Config
        do {
            config2 = try ConfigParser.parse(generated)
        } catch {
            XCTFail("Failed to parse string with error: \(error)")
            return
        }

        XCTAssertEqual(config1, config2)
    }

    static var allTests = [
        ("testParseString", testParseString),
        ("testParseTypes", testParseTypes),
        ("testSubscripts", testSubscripts),
        ("testGenerate", testGenerate),
    ]
}
