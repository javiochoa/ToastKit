// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

@available(macOS 14.0, *)
@available(iOS 16, *)
public struct CustomToast: View {
  @State private var disappearTask: Task<(), Never>?
  @Binding var isVisible: Bool
  let title: String
  let toastColor: ToastColorTypes
  let transitionType: ToastTransitionType
  let animation: Animation
  let autoDisappear: Bool
  let autoDisappearDuration: TimeInterval
  let maxWidth: Bool
  
  let subtitle: String
  let textStack: [String]
  
  let font: String
  let titleFontSize: CGFloat
  let titleFontWeight: Font.Weight
  let titleFontColor: Color
  
  let subtitleFontSize: CGFloat
  let subtitleFontWeight: Font.Weight
  let subtitleFontColor: Color
  
  let multilineTextAlignment: TextAlignment
  
  let innerHpadding: CGFloat
  let innerVpadding: CGFloat
  let outterHpadding: CGFloat
  let stackAligment: Alignment
  let stackAligmentMargin: CGFloat
  let isStackMaxHeight: Bool
  
  let cornerRadius: CGFloat
  
  let shadowColor: Color
  let shadowRadius: CGFloat
  let shadowX: CGFloat
  let shadowY: CGFloat
  
  let withIcon: Bool
  let iconName: String?
  let iconSize: CGFloat?
  let iconColor: Color?
  
  let withSfsymbol: Bool
  let sfSymbolName: String?
  let sfSymbolSize: CGFloat?
  let sfSymbolColor: Color?
  
  let layoutDirection: LayoutDirection
  
  let closeSFicon: String
  let closeSFiconSize: CGFloat
  let closeSFiconColor: Color
  
  let isGlass: Bool
  let glassColor: Color
  
  init(
    isVisible: Binding<Bool>,
    title: String = "",
    toastColor: ToastColorTypes = .success,
    transitionType: ToastTransitionType = .move(edge: .top),
    animation: Animation = .snappy,
    autoDisappear: Bool = true,
    autoDisappearDuration: TimeInterval = 2.0,
    maxWidth: Bool = false,
    
    subtitle: String = "",
    textStack: [String] = [],
    
    font: String = "SFProDisplay",
    titleFontSize: CGFloat = 16,
    titleFontWeight: Font.Weight = .regular,
    titleFontColor: Color = .white,
    
    subtitleFontSize: CGFloat = 14,
    subtitleFontWeight: Font.Weight = .regular,
    subtitleFontColor: Color = .white,
    
    multilineTextAlignment: TextAlignment = .center,
    
    innerHpadding: CGFloat = 20,
    innerVpadding: CGFloat = 10,
    outterHpadding: CGFloat = 20,
    stackAligment: Alignment = .top,
    stackAligmentMargin: CGFloat = 0,
    isStackMaxHeight: Bool = true,
    
    cornerRadius: CGFloat = 12,
    
    shadowColor: Color = .black.opacity(0.2),
    shadowRadius: CGFloat = 10,
    shadowX: CGFloat = 0,
    shadowY: CGFloat = 4,
    
    withIcon: Bool = false,
    iconName: String? = nil,
    iconSize: CGFloat? = nil,
    iconColor: Color? = nil,
    
    withSfsymbol: Bool = false,
    sfSymbolName: String? = nil,
    sfSymbolSize: CGFloat? = nil,
    sfSymbolColor: Color? = nil,
    
    layoutDirection: LayoutDirection = .leftToRight,
    
    closeSFicon: String = "x.circle",
    closeSFiconSize: CGFloat = 18,
    closeSFiconColor: Color = .white,
    
    isGlass: Bool = false,
    glassColor: Color = .clear
  ) {
    _isVisible = isVisible
      self.title = title
    self.toastColor = toastColor
    self.transitionType = transitionType
    self.subtitle = subtitle
    self.textStack = textStack
    self.autoDisappear = autoDisappear
    self.autoDisappearDuration = autoDisappearDuration
    self.animation = animation
    self.maxWidth = maxWidth
    
    self.font = font
    self.titleFontSize = titleFontSize
    self.titleFontWeight = titleFontWeight
    self.titleFontColor = titleFontColor
    
    self.subtitleFontSize = subtitleFontSize
    self.subtitleFontWeight = subtitleFontWeight
    self.subtitleFontColor = subtitleFontColor
    
    self.multilineTextAlignment = multilineTextAlignment
    
    self.innerHpadding = innerHpadding
    self.innerVpadding = innerVpadding
    self.outterHpadding = outterHpadding
    self.stackAligment = stackAligment
    self.stackAligmentMargin = stackAligmentMargin
    self.isStackMaxHeight = isStackMaxHeight
    
    self.cornerRadius = cornerRadius
    
    self.shadowColor = shadowColor
    self.shadowRadius = shadowRadius
    self.shadowX = shadowX
    self.shadowY = shadowY
    
    self.withIcon = withIcon
    self.iconName = iconName
    self.iconSize = iconSize
    self.iconColor = iconColor
    
    self.withSfsymbol = withSfsymbol
    self.sfSymbolName = sfSymbolName
    self.sfSymbolSize = sfSymbolSize
    self.sfSymbolColor = sfSymbolColor
    
    self.layoutDirection = layoutDirection
    
    self.closeSFicon = closeSFicon
    self.closeSFiconSize = closeSFiconSize
    self.closeSFiconColor = closeSFiconColor
    
    self.isGlass = isGlass
    self.glassColor = glassColor
  }

  private var stackAligmentEdgeInsets: EdgeInsets {
    EdgeInsets(
      top: stackAligment.vertical == .top ? stackAligmentMargin : 0,
      leading: stackAligment.horizontal == .leading ? stackAligmentMargin : 0,
      bottom: stackAligment.vertical == .bottom ? stackAligmentMargin : 0,
      trailing: stackAligment.horizontal == .trailing ? stackAligmentMargin : 0
    )
  }

  private var visibleTextStack: [String] {
    let configuredTextStack = textStack.filter { !$0.isEmpty }
    guard !configuredTextStack.isEmpty else {
      return [title, subtitle].filter { !$0.isEmpty }
    }

    return ([title] + configuredTextStack + [subtitle]).filter { !$0.isEmpty }
  }

  private var textStackAlignment: HorizontalAlignment {
    switch multilineTextAlignment {
    case .leading:
      return .leading
    case .trailing:
      return .trailing
    case .center:
      return .center
    }
  }
  
  public var body: some View {
    ZStack(alignment: stackAligment) {
      if isVisible {
        HStack(spacing: 20) {
          if withSfsymbol {
            Image(systemName: sfSymbolName ?? "")
              .renderingMode(.template)
              .resizable()
              .scaledToFit()
              .frame(width: sfSymbolSize, height: sfSymbolSize)
              .foregroundStyle(sfSymbolColor ?? .clear)
          } else if withIcon {
            Image(iconName ?? "")
              .resizable()
              .renderingMode(iconColor != nil ? .template : .original)
              .scaledToFit()
              .foregroundStyle(iconColor ?? .clear)
              .frame(width: iconSize, height: iconSize)
          }

          VStack(alignment: textStackAlignment, spacing: 2) {
            ForEach(Array(visibleTextStack.enumerated()), id: \.offset) { index, text in
              Text(text.toMarkdown)
                .font(.custom(font, size: index == 0 ? titleFontSize : subtitleFontSize))
                .fontWeight(index == 0 ? titleFontWeight : subtitleFontWeight)
//                .foregroundStyle(index == 0 ? titleFontColor : subtitleFontColor)
//                .multilineTextAlignment(multilineTextAlignment)
            }
          }
        }
        .environment(\.layoutDirection, layoutDirection)
        .padding(.horizontal, innerHpadding)
        .padding(.vertical, innerVpadding)
        .if(maxWidth) { $0.frame(maxWidth: .infinity)}
        .background(toastColor.value)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .transition(transition(for: transitionType))
        .shadow(color: shadowColor, radius: shadowRadius, x: shadowX, y: shadowY)
        .overlay {
          if !autoDisappear {
            ZStack {
              Button {
                isVisible = false
              } label: {
                Image(systemName: closeSFicon)
                  .renderingMode(.template)
                  .resizable()
                  .scaledToFit()
                  .frame(width: closeSFiconSize, height: closeSFiconSize)
                  .foregroundStyle(closeSFiconColor)
              }
              .offset(x: -7, y: 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
          }
        }
        .padding(.horizontal, outterHpadding)
        .background {
          if #available(iOS 26.0, macOS 26.0, *), isGlass {
            Color.clear.glassEffect(.regular.tint(glassColor))
          }
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: stackAligment)
    .padding(stackAligmentEdgeInsets)
    .if(isStackMaxHeight) { $0.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: stackAligment)}
    .onChange(of: isVisible) { newValue in
      if newValue {
        disappearTask?.cancel()
        if autoDisappear {
          disappearTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(autoDisappearDuration * 1_000_000_000))
            if !Task.isCancelled {
              isVisible = false
            }
          }
        }
      } else {
        disappearTask?.cancel()
        disappearTask = nil
      }
    }
    .animation(animation, value: isVisible)
  }
  
  func transition(for type: ToastTransitionType) -> AnyTransition {
    switch type {
    case .fade:
      return .opacity
    case .scale:
      return .scale
    case .slide:
      return .slide
    case .move(let edge):
      return .move(edge: edge).combined(with: .opacity)
    case .custom(let transition):
      return transition
    }
  }
}

