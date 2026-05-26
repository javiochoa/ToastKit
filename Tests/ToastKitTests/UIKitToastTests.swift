#if canImport(UIKit)
import UIKit
import XCTest
@testable import ToastKit

@available(iOS 16.0, *)
@MainActor
final class UIKitToastTests: XCTestCase {
    func testConfigurationCanUseContentViewWithoutTitle() {
        let contentView = UILabel()

        let configuration = UIKitToastConfiguration(
            contentView: contentView,
            toastColor: .info
        )

        XCTAssertEqual(configuration.title, "")
        XCTAssertTrue(configuration.contentView === contentView)
        XCTAssertEqual(configuration.toastColor.value, .blue)
    }
}
#endif
