import XCTest
@testable import Env

final class EnvTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Env().text, "Hello, World!")
    }
}
