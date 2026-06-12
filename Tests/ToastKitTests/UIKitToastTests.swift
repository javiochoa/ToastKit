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

    func testToastViewExposesTitleAndSubtitleToAccessibility() throws {
        let animationsWereEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(animationsWereEnabled) }

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let parentView = UIView(frame: window.bounds)
        let anchorView = UIView(frame: CGRect(x: 100, y: 120, width: 80, height: 32))

        window.addSubview(parentView)
        parentView.addSubview(anchorView)

        let presentation = parentView.showToast(
            UIKitToastConfiguration(
                title: "**Saved**",
                subtitle: "Profile updated",
                position: .attached(to: anchorView, edge: .bottom, offset: 8),
                autoDisappear: false
            )
        )

        let toastView = try XCTUnwrap(parentView.subviews.first { $0 !== anchorView })
        XCTAssertTrue(toastView.isAccessibilityElement)
        XCTAssertEqual(toastView.accessibilityLabel, "Saved. Profile updated")
        XCTAssertEqual(toastView.accessibilityTraits, .staticText)
        XCTAssertEqual(toastView.accessibilityCustomActions?.first?.name, "Dismiss toast")

        presentation.dismiss(animated: false)
        XCTAssertNil(toastView.superview)
    }

    func testContentViewToastUsesReadableContentForAccessibility() throws {
        let animationsWereEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(animationsWereEnabled) }

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let parentView = UIView(frame: window.bounds)
        let anchorView = UIView(frame: CGRect(x: 100, y: 120, width: 80, height: 32))
        let statusView = UIStackView()
        let titleLabel = UILabel()
        let subtitleLabel = UILabel()

        titleLabel.text = "Upload complete"
        subtitleLabel.text = "12 files synced"
        statusView.axis = .vertical
        statusView.addArrangedSubview(titleLabel)
        statusView.addArrangedSubview(subtitleLabel)

        window.addSubview(parentView)
        parentView.addSubview(anchorView)

        let presentation = parentView.showToast(
            UIKitToastConfiguration(
                contentView: statusView,
                position: .attached(to: anchorView, edge: .bottom, offset: 8),
                autoDisappear: false
            )
        )

        let toastView = try XCTUnwrap(parentView.subviews.first { $0 !== anchorView })
        XCTAssertTrue(toastView.isAccessibilityElement)
        XCTAssertEqual(toastView.accessibilityLabel, "Upload complete. 12 files synced")

        presentation.dismiss(animated: false)
        XCTAssertNil(toastView.superview)
    }

    func testToastViewHasTapGestureForDismissal() throws {
        let animationsWereEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(animationsWereEnabled) }

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let parentView = UIView(frame: window.bounds)

        window.addSubview(parentView)

        let presentation = parentView.showToast(
            UIKitToastConfiguration(
                title: "Saved",
                position: .attached(to: parentView, edge: .center),
                autoDisappear: false
            )
        )

        let toastView = try XCTUnwrap(parentView.subviews.first)
        let tapGesture = try XCTUnwrap(toastView.gestureRecognizers?.compactMap { $0 as? UITapGestureRecognizer }.first)
        XCTAssertFalse(tapGesture.cancelsTouchesInView)

        presentation.dismiss(animated: false)
        XCTAssertNil(toastView.superview)
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

    func testAttachedToastOffsetUsesTransformedAnchorFrame() throws {
        let animationsWereEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(animationsWereEnabled) }

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 400, height: 600))
        let parentView = UIView(frame: window.bounds)
        let anchorView = UIButton(frame: CGRect(x: 150, y: 220, width: 80, height: 32))
        let offset: CGFloat = 24

        anchorView.transform = CGAffineTransform(translationX: 0, y: 40)
        window.addSubview(parentView)
        parentView.addSubview(anchorView)
        window.layoutIfNeeded()

        let presentation = parentView.showToast(
            UIKitToastConfiguration(
                title: "Saved",
                position: .attached(to: anchorView, edge: .bottom, offset: offset),
                autoDisappear: false
            )
        )
        parentView.layoutIfNeeded()

        let toastView = try XCTUnwrap(parentView.subviews.first { $0 !== anchorView })
        let anchorFrame = anchorView.convert(anchorView.bounds, to: parentView)
        XCTAssertEqual(toastView.frame.minY - anchorFrame.maxY, offset, accuracy: 0.5)

        presentation.dismiss(animated: false)
        XCTAssertNil(toastView.superview)
    }
}
#endif
