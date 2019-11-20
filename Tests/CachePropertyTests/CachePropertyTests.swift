import XCTest
@testable import CacheProperty

final class CachePropertyTests: XCTestCase {
    static var loadValue: (NSString) -> NSNumber = {
        switch $0 {
        case "key":
            return 1
        case "key2":
            return 2
        default:
            return 1
        }
    }

    @Cache<NSString, NSNumber>(key: "default", missing: loadValue) var cached: NSNumber
//    @Cache<String, Int>(key: "default", storage: NSCacheWrapper<String, Int>(), missing: loadValue) var cached: Int

    func testExample() {
        XCTAssertEqual(cached, 1)
    }
    
    func testReset() {
        XCTAssertEqual(cached, 1)

        _cached.reset()
        _cached.missing = { _ in
            return 10
        }
        XCTAssertEqual(cached, 10)
    }
    
    func testKey() {
        _cached.reset()
        _cached.key = "key2"
        XCTAssertEqual(cached, 2)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
