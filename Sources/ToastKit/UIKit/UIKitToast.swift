#if canImport(UIKit)
import SwiftUI
import UIKit

@available(iOS 16.0, *)
public enum UIKitToastPosition {
    case top
    case bottom
}

@available(iOS 16.0, *)
public struct UIKitToastConfiguration {
    public var title: String
    public var subtitle: String
    public var toastColor: ToastColorTypes
    public var position: UIKitToastPosition
    public var autoDisappear: Bool
    public var autoDisappearDuration: TimeInterval
    public var maxWidth: Bool

    public var fontName: String?
    public var titleFontSize: CGFloat
    public var titleFontWeight: UIFont.Weight
    public var titleFontColor: UIColor
    public var subtitleFontSize: CGFloat
    public var subtitleFontWeight: UIFont.Weight
    public var subtitleFontColor: UIColor
    public var multilineTextAlignment: NSTextAlignment

    public var innerHpadding: CGFloat
    public var innerVpadding: CGFloat
    public var outerHpadding: CGFloat
    public var outerVpadding: CGFloat
    public var toastSpacing: CGFloat
    public var cornerRadius: CGFloat

    public var shadowColor: UIColor
    public var shadowOpacity: Float
    public var shadowRadius: CGFloat
    public var shadowOffset: CGSize

    public var iconImage: UIImage?
    public var iconName: String?
    public var iconSize: CGSize
    public var iconTintColor: UIColor?

    public var sfSymbolName: String?
    public var sfSymbolSize: CGSize
    public var sfSymbolColor: UIColor

    public var layoutDirection: UIUserInterfaceLayoutDirection

    public var closeSFIcon: String
    public var closeSFIconSize: CGSize
    public var closeSFIconColor: UIColor

    public var blurEffectStyle: UIBlurEffect.Style?

    public init(
        title: String,
        subtitle: String = "",
        toastColor: ToastColorTypes = .success,
        position: UIKitToastPosition = .top,
        autoDisappear: Bool = true,
        autoDisappearDuration: TimeInterval = 2.0,
        maxWidth: Bool = false,
        fontName: String? = "SFProDisplay",
        titleFontSize: CGFloat = 16,
        titleFontWeight: UIFont.Weight = .regular,
        titleFontColor: UIColor = .black,
        subtitleFontSize: CGFloat = 14,
        subtitleFontWeight: UIFont.Weight = .regular,
        subtitleFontColor: UIColor = .black,
        multilineTextAlignment: NSTextAlignment = .center,
        innerHpadding: CGFloat = 20,
        innerVpadding: CGFloat = 10,
        outerHpadding: CGFloat = 20,
        outerVpadding: CGFloat = 12,
        toastSpacing: CGFloat = 8,
        cornerRadius: CGFloat = 12,
        shadowColor: UIColor = .black,
        shadowOpacity: Float = 0.2,
        shadowRadius: CGFloat = 10,
        shadowOffset: CGSize = CGSize(width: 0, height: 4),
        iconImage: UIImage? = nil,
        iconName: String? = nil,
        iconSize: CGSize = CGSize(width: 24, height: 24),
        iconTintColor: UIColor? = nil,
        sfSymbolName: String? = nil,
        sfSymbolSize: CGSize = CGSize(width: 24, height: 24),
        sfSymbolColor: UIColor = .white,
        layoutDirection: UIUserInterfaceLayoutDirection = .leftToRight,
        closeSFIcon: String = "x.circle",
        closeSFIconSize: CGSize = CGSize(width: 18, height: 18),
        closeSFIconColor: UIColor = .white,
        blurEffectStyle: UIBlurEffect.Style? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.toastColor = toastColor
        self.position = position
        self.autoDisappear = autoDisappear
        self.autoDisappearDuration = autoDisappearDuration
        self.maxWidth = maxWidth
        self.fontName = fontName
        self.titleFontSize = titleFontSize
        self.titleFontWeight = titleFontWeight
        self.titleFontColor = titleFontColor
        self.subtitleFontSize = subtitleFontSize
        self.subtitleFontWeight = subtitleFontWeight
        self.subtitleFontColor = subtitleFontColor
        self.multilineTextAlignment = multilineTextAlignment
        self.innerHpadding = innerHpadding
        self.innerVpadding = innerVpadding
        self.outerHpadding = outerHpadding
        self.outerVpadding = outerVpadding
        self.toastSpacing = toastSpacing
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.shadowOpacity = shadowOpacity
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
        self.iconImage = iconImage
        self.iconName = iconName
        self.iconSize = iconSize
        self.iconTintColor = iconTintColor
        self.sfSymbolName = sfSymbolName
        self.sfSymbolSize = sfSymbolSize
        self.sfSymbolColor = sfSymbolColor
        self.layoutDirection = layoutDirection
        self.closeSFIcon = closeSFIcon
        self.closeSFIconSize = closeSFIconSize
        self.closeSFIconColor = closeSFIconColor
        self.blurEffectStyle = blurEffectStyle
    }
}

@available(iOS 16.0, *)
@MainActor
public final class UIKitToastPresentation {
    private weak var containerView: UIView?
    private weak var toastView: UIKitToastView?
    private var dismissalWorkItem: DispatchWorkItem?

    fileprivate init(
        containerView: UIView,
        toastView: UIKitToastView,
        dismissalWorkItem: DispatchWorkItem?
    ) {
        self.containerView = containerView
        self.toastView = toastView
        self.dismissalWorkItem = dismissalWorkItem
    }

    public func dismiss(animated: Bool = true) {
        dismissalWorkItem?.cancel()
        dismissalWorkItem = nil

        guard let toastView else { return }
        UIKitToastAnimator.dismiss(toastView, in: containerView, animated: animated)
    }
}

@available(iOS 16.0, *)
@MainActor
public extension UIView {
    @discardableResult
    func showToast(_ configuration: UIKitToastConfiguration) -> UIKitToastPresentation {
        let toastView = UIKitToastView(configuration: configuration)
        let stackView = toastStackView(for: configuration)

        toastView.translatesAutoresizingMaskIntoConstraints = false
        toastView.onClose = { [weak toastView, weak self] in
            guard let toastView else { return }
            UIKitToastAnimator.dismiss(toastView, in: self, animated: true)
        }

        if configuration.position == .top {
            stackView.insertArrangedSubview(toastView, at: 0)
        } else {
            stackView.addArrangedSubview(toastView)
        }

        let widthConstraint: NSLayoutConstraint
        if configuration.maxWidth {
            widthConstraint = toastView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -(configuration.outerHpadding * 2))
        } else {
            widthConstraint = toastView.widthAnchor.constraint(lessThanOrEqualTo: stackView.widthAnchor, constant: -(configuration.outerHpadding * 2))
        }
        widthConstraint.isActive = true

        layoutIfNeeded()
        UIKitToastAnimator.present(toastView)

        let workItem: DispatchWorkItem?
        if configuration.autoDisappear {
            let item = DispatchWorkItem { [weak self, weak toastView] in
                guard let toastView else { return }
                UIKitToastAnimator.dismiss(toastView, in: self, animated: true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + configuration.autoDisappearDuration, execute: item)
            workItem = item
        } else {
            workItem = nil
        }

        return UIKitToastPresentation(
            containerView: self,
            toastView: toastView,
            dismissalWorkItem: workItem
        )
    }

    @discardableResult
    func showToast(
        title: String,
        toastColor: ToastColorTypes = .success,
        position: UIKitToastPosition = .top,
        autoDisappearDuration: TimeInterval = 2.0
    ) -> UIKitToastPresentation {
        showToast(
            UIKitToastConfiguration(
                title: title,
                toastColor: toastColor,
                position: position,
                autoDisappearDuration: autoDisappearDuration
            )
        )
    }

    @discardableResult
    func showSuccessToast(title: String, autoDisappearDuration: TimeInterval = 2.0) -> UIKitToastPresentation {
        showToast(title: title, toastColor: .success, autoDisappearDuration: autoDisappearDuration)
    }

    @discardableResult
    func showWarningToast(title: String, autoDisappearDuration: TimeInterval = 2.0) -> UIKitToastPresentation {
        showToast(title: title, toastColor: .warning, autoDisappearDuration: autoDisappearDuration)
    }

    @discardableResult
    func showErrorToast(title: String, autoDisappearDuration: TimeInterval = 2.0) -> UIKitToastPresentation {
        showToast(title: title, toastColor: .error, autoDisappearDuration: autoDisappearDuration)
    }

    @discardableResult
    func showInfoToast(title: String, autoDisappearDuration: TimeInterval = 2.0) -> UIKitToastPresentation {
        showToast(title: title, toastColor: .info, autoDisappearDuration: autoDisappearDuration)
    }
}

@available(iOS 16.0, *)
@MainActor
public extension UIViewController {
    @discardableResult
    func showToast(_ configuration: UIKitToastConfiguration) -> UIKitToastPresentation {
        view.showToast(configuration)
    }

    @discardableResult
    func showToast(
        title: String,
        toastColor: ToastColorTypes = .success,
        position: UIKitToastPosition = .top,
        autoDisappearDuration: TimeInterval = 2.0
    ) -> UIKitToastPresentation {
        view.showToast(
            title: title,
            toastColor: toastColor,
            position: position,
            autoDisappearDuration: autoDisappearDuration
        )
    }

    @discardableResult
    func showSuccessToast(title: String, autoDisappearDuration: TimeInterval = 2.0) -> UIKitToastPresentation {
        view.showSuccessToast(title: title, autoDisappearDuration: autoDisappearDuration)
    }

    @discardableResult
    func showWarningToast(title: String, autoDisappearDuration: TimeInterval = 2.0) -> UIKitToastPresentation {
        view.showWarningToast(title: title, autoDisappearDuration: autoDisappearDuration)
    }

    @discardableResult
    func showErrorToast(title: String, autoDisappearDuration: TimeInterval = 2.0) -> UIKitToastPresentation {
        view.showErrorToast(title: title, autoDisappearDuration: autoDisappearDuration)
    }

    @discardableResult
    func showInfoToast(title: String, autoDisappearDuration: TimeInterval = 2.0) -> UIKitToastPresentation {
        view.showInfoToast(title: title, autoDisappearDuration: autoDisappearDuration)
    }
}

@available(iOS 16.0, *)
private final class UIKitToastView: UIView {
    let position: UIKitToastPosition
    var onClose: (() -> Void)?

    private let configuration: UIKitToastConfiguration

    init(configuration: UIKitToastConfiguration) {
        self.configuration = configuration
        self.position = configuration.position
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        semanticContentAttribute = configuration.layoutDirection.semanticContentAttribute
        backgroundColor = configuration.resolvedBackgroundColor
        layer.cornerRadius = configuration.cornerRadius
        layer.shadowColor = configuration.shadowColor.cgColor
        layer.shadowOpacity = configuration.shadowOpacity
        layer.shadowRadius = configuration.shadowRadius
        layer.shadowOffset = configuration.shadowOffset

        if let blurEffectStyle = configuration.resolvedBlurEffectStyle {
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: blurEffectStyle))
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = configuration.cornerRadius
            blurView.clipsToBounds = true
            addSubview(blurView)

            NSLayoutConstraint.activate([
                blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
                blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
                blurView.topAnchor.constraint(equalTo: topAnchor),
                blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }

        let contentStack = UIStackView()
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = 20
        contentStack.semanticContentAttribute = configuration.layoutDirection.semanticContentAttribute
        addSubview(contentStack)

        if let iconView = makeIconView() {
            contentStack.addArrangedSubview(iconView)
        }

        contentStack.addArrangedSubview(makeTextStack())

        if !configuration.autoDisappear {
            contentStack.addArrangedSubview(makeCloseButton())
        }

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: configuration.innerHpadding),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -configuration.innerHpadding),
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: configuration.innerVpadding),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -configuration.innerVpadding)
        ])
    }

    private func makeTextStack() -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.attributedText = configuration.markdownAttributedText(
            from: configuration.title,
            size: configuration.titleFontSize,
            weight: configuration.titleFontWeight,
            color: configuration.titleFontColor
        )
        titleLabel.textAlignment = configuration.multilineTextAlignment
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true

        let textStack = UIStackView(arrangedSubviews: [titleLabel])
        textStack.axis = .vertical
        textStack.alignment = configuration.multilineTextAlignment.stackAlignment
        textStack.spacing = 2

        if !configuration.subtitle.isEmpty {
            let subtitleLabel = UILabel()
            subtitleLabel.attributedText = configuration.markdownAttributedText(
                from: configuration.subtitle,
                size: configuration.subtitleFontSize,
                weight: configuration.subtitleFontWeight,
                color: configuration.subtitleFontColor
            )
            subtitleLabel.textAlignment = configuration.multilineTextAlignment
            subtitleLabel.numberOfLines = 0
            subtitleLabel.adjustsFontForContentSizeCategory = true
            textStack.addArrangedSubview(subtitleLabel)
        }

        return textStack
    }

    private func makeIconView() -> UIImageView? {
        let image: UIImage?
        let size: CGSize
        let tintColor: UIColor?

        if let sfSymbolName = configuration.sfSymbolName {
            image = UIImage(systemName: sfSymbolName)
            size = configuration.sfSymbolSize
            tintColor = configuration.sfSymbolColor
        } else if let iconImage = configuration.iconImage {
            image = iconImage
            size = configuration.iconSize
            tintColor = configuration.iconTintColor
        } else if let iconName = configuration.iconName {
            image = UIImage(named: iconName)
            size = configuration.iconSize
            tintColor = configuration.iconTintColor
        } else {
            return nil
        }

        guard let image else { return nil }

        let imageView = UIImageView(image: tintColor == nil ? image : image.withRenderingMode(.alwaysTemplate))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = tintColor

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: size.width),
            imageView.heightAnchor.constraint(equalToConstant: size.height)
        ])

        return imageView
    }

    private func makeCloseButton() -> UIButton {
        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.tintColor = configuration.closeSFIconColor
        closeButton.accessibilityLabel = "Dismiss toast"

        if let image = UIImage(systemName: configuration.closeSFIcon) {
            closeButton.setImage(image, for: .normal)
        }

        closeButton.addAction(
            UIAction { [weak self] _ in
                self?.onClose?()
            },
            for: .touchUpInside
        )

        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: configuration.closeSFIconSize.width),
            closeButton.heightAnchor.constraint(equalToConstant: configuration.closeSFIconSize.height)
        ])

        return closeButton
    }
}

@available(iOS 16.0, *)
@MainActor
private enum UIKitToastAnimator {
    static func present(_ toastView: UIKitToastView) {
        toastView.alpha = 0
        toastView.transform = toastView.position.presentingTransform

        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            usingSpringWithDamping: 0.84,
            initialSpringVelocity: 0.45,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            toastView.alpha = 1
            toastView.transform = .identity
            toastView.superview?.layoutIfNeeded()
        }
    }

    static func dismiss(_ toastView: UIKitToastView, in containerView: UIView?, animated: Bool) {
        guard toastView.superview != nil else { return }

        let removeToast = {
            let stackView = toastView.superview as? UIStackView
            stackView?.removeArrangedSubview(toastView)
            toastView.removeFromSuperview()

            if let stackView, stackView.arrangedSubviews.isEmpty {
                stackView.removeFromSuperview()
                containerView?.clearToastStack(for: toastView.position)
            }
        }

        guard animated else {
            removeToast()
            return
        }

        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            toastView.alpha = 0
            toastView.transform = toastView.position.presentingTransform
        } completion: { _ in
            removeToast()
        }
    }
}

@available(iOS 16.0, *)
@MainActor
private var topToastStackKey: UInt8 = 0

@available(iOS 16.0, *)
@MainActor
private var bottomToastStackKey: UInt8 = 0

@available(iOS 16.0, *)
@MainActor
private extension UIView {
    func toastStackView(for configuration: UIKitToastConfiguration) -> UIStackView {
        if let stackView = existingToastStack(for: configuration.position) {
            stackView.spacing = configuration.toastSpacing
            return stackView
        }

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = configuration.toastSpacing
        stackView.isUserInteractionEnabled = true
        addSubview(stackView)

        let guide = safeAreaLayoutGuide
        let verticalConstraint: NSLayoutConstraint
        switch configuration.position {
        case .top:
            verticalConstraint = stackView.topAnchor.constraint(equalTo: guide.topAnchor, constant: configuration.outerVpadding)
        case .bottom:
            verticalConstraint = stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -configuration.outerVpadding)
        }

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            verticalConstraint
        ])

        setToastStack(stackView, for: configuration.position)
        return stackView
    }

    func existingToastStack(for position: UIKitToastPosition) -> UIStackView? {
        let key = toastStackKey(for: position)
        guard let stackView = objc_getAssociatedObject(self, key) as? UIStackView else { return nil }
        return stackView.superview === self ? stackView : nil
    }

    func setToastStack(_ stackView: UIStackView, for position: UIKitToastPosition) {
        objc_setAssociatedObject(self, toastStackKey(for: position), stackView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func clearToastStack(for position: UIKitToastPosition) {
        objc_setAssociatedObject(self, toastStackKey(for: position), nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func toastStackKey(for position: UIKitToastPosition) -> UnsafeRawPointer {
        switch position {
        case .top:
            return UnsafeRawPointer(&topToastStackKey)
        case .bottom:
            return UnsafeRawPointer(&bottomToastStackKey)
        }
    }
}

@available(iOS 16.0, *)
private extension UIKitToastConfiguration {
    var resolvedBackgroundColor: UIColor {
        guard resolvedBlurEffectStyle == nil else { return .clear }
        return toastColor.uiColor
    }

    var resolvedBlurEffectStyle: UIBlurEffect.Style? {
        if let blurEffectStyle { return blurEffectStyle }

        if case .glass = toastColor {
            return .systemUltraThinMaterial
        }

        return nil
    }

    func scaledFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let baseFont: UIFont
        if let fontName, let customFont = UIFont(name: fontName, size: size) {
            baseFont = customFont
        } else {
            baseFont = .systemFont(ofSize: size, weight: weight)
        }

        return UIFontMetrics.default.scaledFont(for: baseFont)
    }

    func markdownAttributedText(
        from markdown: String,
        size: CGFloat,
        weight: UIFont.Weight,
        color: UIColor
    ) -> NSAttributedString {
        let attributedText: NSMutableAttributedString
        do {
            attributedText = NSMutableAttributedString(attributedString: try NSAttributedString(markdown: markdown))
        } catch {
            attributedText = NSMutableAttributedString(string: markdown)
        }

        let fullRange = NSRange(location: 0, length: attributedText.length)
        guard fullRange.length > 0 else { return attributedText }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = multilineTextAlignment

        attributedText.addAttributes([
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ], range: fullRange)

        var intentRanges: [(NSRange, InlinePresentationIntent?)] = []
        attributedText.enumerateAttribute(.inlinePresentationIntent, in: fullRange) { value, range, _ in
            intentRanges.append((range, value as? InlinePresentationIntent))
        }

        for (range, intent) in intentRanges {
            attributedText.addAttribute(.font, value: markdownFont(size: size, weight: weight, intent: intent), range: range)

            if intent?.contains(.strikethrough) == true {
                attributedText.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            }
        }

        attributedText.enumerateAttribute(.link, in: fullRange) { value, range, _ in
            guard value != nil else { return }
            attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }

        insertListMarkers(into: attributedText, size: size, weight: weight, color: color)

        let updatedFullRange = NSRange(location: 0, length: attributedText.length)
        attributedText.removeAttribute(.presentationIntentAttributeName, range: updatedFullRange)
        if #available(iOS 26.0, *) {
            attributedText.removeAttribute(.listItemDelimiter, range: updatedFullRange)
        }

        return attributedText
    }

    func insertListMarkers(
        into attributedText: NSMutableAttributedString,
        size: CGFloat,
        weight: UIFont.Weight,
        color: UIColor
    ) {
        let fullRange = NSRange(location: 0, length: attributedText.length)
        guard fullRange.length > 0 else { return }

        var insertions: [(location: Int, prefix: String)] = []
        var seenParagraphStarts = Set<Int>()
        let markdownString = attributedText.string as NSString

        attributedText.enumerateAttribute(.presentationIntentAttributeName, in: fullRange) { value, range, _ in
            guard
                let intent = value as? PresentationIntent,
                let listMarker = listMarker(for: intent)
            else { return }

            let paragraphRange = markdownString.paragraphRange(for: NSRange(location: range.location, length: 0))
            guard seenParagraphStarts.insert(paragraphRange.location).inserted else { return }
            guard !paragraphAlreadyHasListMarker(in: markdownString, paragraphRange: paragraphRange) else { return }

            let indent = String(repeating: "    ", count: listDepth(for: intent))
            insertions.append((paragraphRange.location, "\(indent)\(listMarker) "))
        }

        let markerAttributes: [NSAttributedString.Key: Any] = [
            .font: scaledFont(size: size, weight: weight),
            .foregroundColor: color
        ]

        for insertion in insertions.sorted(by: { $0.location > $1.location }) {
            attributedText.insert(
                NSAttributedString(string: insertion.prefix, attributes: markerAttributes),
                at: insertion.location
            )
        }
    }

    func listMarker(for intent: PresentationIntent) -> String? {
        var listItem: (index: Int, ordinal: Int)?

        for (index, component) in intent.components.enumerated() {
            if case .listItem(let ordinal) = component.kind {
                listItem = (index, ordinal)
            }
        }

        guard let listItem else { return nil }

        for component in intent.components.prefix(listItem.index).reversed() {
            switch component.kind {
            case .orderedList:
                return "\(listItem.ordinal)."
            case .unorderedList:
                return "•"
            default:
                continue
            }
        }

        return "•"
    }

    func listDepth(for intent: PresentationIntent) -> Int {
        let depth = intent.components.reduce(0) { partialResult, component in
            switch component.kind {
            case .orderedList, .unorderedList:
                return partialResult + 1
            default:
                return partialResult
            }
        }

        return max(0, depth - 1)
    }

    func paragraphAlreadyHasListMarker(in string: NSString, paragraphRange: NSRange) -> Bool {
        let paragraph = string.substring(with: paragraphRange).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !paragraph.isEmpty else { return false }

        if paragraph.hasPrefix("•") { return true }
        return paragraph.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil
    }

    func markdownFont(size: CGFloat, weight: UIFont.Weight, intent: InlinePresentationIntent?) -> UIFont {
        if intent?.contains(.code) == true {
            return UIFontMetrics.default.scaledFont(for: .monospacedSystemFont(ofSize: size, weight: weight))
        }

        let fontWeight: UIFont.Weight = intent?.contains(.stronglyEmphasized) == true ? .bold : weight
        let baseFont = scaledFont(size: size, weight: fontWeight)
        guard intent?.contains(.emphasized) == true else { return baseFont }

        var traits = baseFont.fontDescriptor.symbolicTraits
        traits.insert(.traitItalic)

        guard let descriptor = baseFont.fontDescriptor.withSymbolicTraits(traits) else { return baseFont }
        return UIFont(descriptor: descriptor, size: baseFont.pointSize)
    }
}

@available(iOS 16.0, *)
private extension ToastColorTypes {
    var uiColor: UIColor {
        switch self {
        case .success:
            return .systemGreen
        case .warning:
            return .systemYellow
        case .error:
            return .systemRed
        case .info:
            return .systemBlue
        case .glass:
            return .clear
        case .custom(let color):
            return UIColor(color)
        }
    }
}

@available(iOS 16.0, *)
private extension UIUserInterfaceLayoutDirection {
    var semanticContentAttribute: UISemanticContentAttribute {
        switch self {
        case .leftToRight:
            return .forceLeftToRight
        case .rightToLeft:
            return .forceRightToLeft
        @unknown default:
            return .unspecified
        }
    }
}

@available(iOS 16.0, *)
private extension NSTextAlignment {
    var stackAlignment: UIStackView.Alignment {
        switch self {
        case .left, .natural, .justified:
            return .leading
        case .center:
            return .center
        case .right:
            return .trailing
        @unknown default:
            return .center
        }
    }
}

@available(iOS 16.0, *)
private extension UIKitToastPosition {
    var presentingTransform: CGAffineTransform {
        switch self {
        case .top:
            return CGAffineTransform(translationX: 0, y: -16)
        case .bottom:
            return CGAffineTransform(translationX: 0, y: 16)
        }
    }
}
#endif
