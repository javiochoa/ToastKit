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

    func testOverlayAttachedToastIsAddedToAnchorWindow() throws {
        let animationsWereEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(animationsWereEnabled) }

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let parentView = UIView(frame: window.bounds)
        let clippedView = UIView(frame: CGRect(x: 40, y: 40, width: 160, height: 80))
        let anchorView = UIButton(frame: CGRect(x: 20, y: 20, width: 80, height: 32))

        clippedView.clipsToBounds = true
        window.addSubview(parentView)
        parentView.addSubview(clippedView)
        clippedView.addSubview(anchorView)

        let presentation = parentView.showToast(
            UIKitToastConfiguration(
                title: "Saved",
                position: .overlayAttached(to: anchorView, edge: .bottom, offset: 8),
                autoDisappear: false
            )
        )

        let toastView = try XCTUnwrap(window.subviews.first { $0 !== parentView })
        XCTAssertTrue(toastView.superview === window)
        XCTAssertFalse(toastView.isDescendant(of: clippedView))

        presentation.dismiss(animated: false)
        XCTAssertNil(toastView.superview)
    }
}
#endif
