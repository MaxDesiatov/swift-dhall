import Covfefe
@testable import Dhall
import XCTest

final class DhallTests: XCTestCase {
  func testExample() throws {
    let test = #"""
    { home       = "/home/bill"
    , privateKey = "/home/bill/.ssh/id_ed25519"
    , publicKey  = "/home/blil/.ssh/id_ed25519.pub"
    }
    """#
    let tree = try syntaxTree(test)
  }
}
