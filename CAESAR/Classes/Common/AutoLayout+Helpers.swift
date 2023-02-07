// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

public protocol AnchorsProviding {
  var leadingAnchor: NSLayoutXAxisAnchor { get }
  var trailingAnchor: NSLayoutXAxisAnchor { get }
  var topAnchor: NSLayoutYAxisAnchor { get }
  var bottomAnchor: NSLayoutYAxisAnchor { get }
  var centerYAnchor: NSLayoutYAxisAnchor { get }
  var centerXAnchor: NSLayoutXAxisAnchor { get }
}

public protocol SizeAnchorProviding {
  var heightAnchor: NSLayoutDimension { get }
  var widthAnchor: NSLayoutDimension { get }
}

extension UIView: AnchorsProviding {}
extension UILayoutGuide: AnchorsProviding {}

extension UIView: SizeAnchorProviding {}

extension UIView {
  public func autoLayout() -> Self {
    translatesAutoresizingMaskIntoConstraints = false
    return self
  }

  public struct EdgeConstraints {
    public let top: NSLayoutConstraint
    public let leading: NSLayoutConstraint
    public let bottom: NSLayoutConstraint
    public let trailing: NSLayoutConstraint

    public init(
      top: NSLayoutConstraint,
      leading: NSLayoutConstraint,
      bottom: NSLayoutConstraint,
      trailing: NSLayoutConstraint
    ) {
      self.top = top
      self.leading = leading
      self.bottom = bottom
      self.trailing = trailing
    }

    public var allActive: Bool {
      get {
        top.isActive &&
          leading.isActive &&
          bottom.isActive &&
          trailing.isActive
      }
      set {
        top.isActive = newValue
        leading.isActive = newValue
        bottom.isActive = newValue
        trailing.isActive = newValue
      }
    }

    public func update(for insets: UIEdgeInsets) {
      top.constant = insets.top
      leading.constant = insets.left
      trailing.constant = -insets.right
      bottom.constant = -insets.bottom
    }
  }

  public struct SizeConstraints {
    public let height: NSLayoutConstraint
    public let width: NSLayoutConstraint

    public var allActive: Bool {
      get {
        height.isActive && width.isActive
      }
      set {
        height.isActive = newValue
        width.isActive = newValue
      }
    }

    public func update(for size: CGSize) {
      height.constant = size.height
      width.constant = size.width
    }
  }

  // MARK: - Layout definitions

  public enum LayoutDimension {
    case width
    case height
  }

  public enum LayoutEdge: CaseIterable {
    case leading
    case top
    case trailing
    case bottom
  }

  public enum LayoutYAxisEdge {
    case top
    case bottom
  }

  public enum LayoutXAxisEdge {
    case leading
    case trailing
  }

  public enum LayoutAxis {
    case vertical
    case horizontal
  }

  public enum DimensionsRatio {
    case widthToHeight
    case heightToWidth
  }

  // MARK: - Dimension

  @discardableResult
  public func setDimension(
    _ dimension: LayoutDimension,
    to size: CGFloat,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    let anchor: NSLayoutDimension
    switch dimension {
    case .height:
      anchor = heightAnchor
    case .width:
      anchor = widthAnchor
    }
    let constraint = anchor.constraint(equalToConstant: size)
    constraint.priority = priority
    constraint.isActive = true
    return constraint
  }

  @discardableResult
  public func setDimensionsRatio(
    _ type: DimensionsRatio,
    to multiplier: CGFloat,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    let constraint: NSLayoutConstraint

    switch type {
    case .widthToHeight:
      constraint =
        widthAnchor.constraint(equalTo: heightAnchor, multiplier: multiplier)
    case .heightToWidth:
      constraint =
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: multiplier)
    }

    constraint.priority = priority
    constraint.isActive = true
    return constraint
  }

  @discardableResult
  public func setDimension(
    _ dimension: LayoutDimension,
    greaterThanOrEqualTo size: CGFloat
  ) -> NSLayoutConstraint {
    let anchor: NSLayoutDimension
    switch dimension {
    case .height:
      anchor = heightAnchor
    case .width:
      anchor = widthAnchor
    }
    let constraint = anchor.constraint(greaterThanOrEqualToConstant: size)
    constraint.isActive = true
    return constraint
  }

  @discardableResult
  public func setDimension(
    _ dimension: LayoutDimension,
    lessThanOrEqualTo size: CGFloat
  ) -> NSLayoutConstraint {
    let anchor: NSLayoutDimension
    switch dimension {
    case .height:
      anchor = heightAnchor
    case .width:
      anchor = widthAnchor
    }
    let constraint = anchor.constraint(lessThanOrEqualToConstant: size)
    constraint.isActive = true
    return constraint
  }

  @discardableResult
  public func setDimensions(to size: CGSize) -> SizeConstraints {
    SizeConstraints(
      height: setDimension(.height, to: size.height),
      width: setDimension(.width, to: size.width)
    )
  }

  @discardableResult
  public func setDimension(
    _ dimension: LayoutDimension,
    equalTo layoutDimension: LayoutDimension,
    of provider: SizeAnchorProviding,
    with offset: CGFloat = 0.0,
    multiplier: CGFloat = 1.0,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    let ownAnchor = anchor(for: dimension)
    let providerAnchor = provider.anchor(for: layoutDimension)
    let constraint = ownAnchor.constraint(
      equalTo: providerAnchor,
      multiplier: multiplier,
      constant: offset
    )
    constraint.priority = priority
    constraint.isActive = true
    return constraint
  }

  @discardableResult
  public func setDimension(
    _ dimension: LayoutDimension,
    lessThanOrEqualTo layoutDimension: LayoutDimension,
    of provider: SizeAnchorProviding,
    with offset: CGFloat = 0.0,
    multiplier: CGFloat = 1.0
  ) -> NSLayoutConstraint {
    let ownAnchor = anchor(for: dimension)
    let providerAnchor = provider.anchor(for: layoutDimension)
    let constraint = ownAnchor.constraint(
      lessThanOrEqualTo: providerAnchor,
      multiplier: multiplier,
      constant: offset
    )
    constraint.isActive = true
    return constraint
  }

  @discardableResult
  public func setDimension(
    _ dimension: LayoutDimension,
    greaterThanOrEqualTo layoutDimension: LayoutDimension,
    of provider: SizeAnchorProviding,
    with offset: CGFloat = 0.0,
    multiplier: CGFloat = 1.0
  ) -> NSLayoutConstraint {
    let ownAnchor = anchor(for: dimension)
    let providerAnchor = provider.anchor(for: layoutDimension)
    let constraint = ownAnchor.constraint(
      greaterThanOrEqualTo: providerAnchor,
      multiplier: multiplier,
      constant: offset
    )
    constraint.isActive = true
    return constraint
  }

  // MARK: - Axis alignment

  @discardableResult
  public func alignToSuperviewAxis(
    _ superviewAxis: LayoutAxis,
    with offset: CGFloat = 0.0,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    guard let superview = superview else {
      fatalError("Can't add constraints without superview")
    }

    return
      alignToAxis(superviewAxis, of: superview, with: offset, priority: priority)
  }

  @discardableResult
  public func alignToAxis(
    _ axis: LayoutAxis,
    of view: AnchorsProviding,
    with offset: CGFloat = 0.0,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    let constraint: NSLayoutConstraint
    switch axis {
    case .vertical:
      constraint = centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: offset)
    case .horizontal:
      constraint = centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: offset)
    }

    constraint.priority = priority
    constraint.isActive = true
    return constraint
  }

  @discardableResult
  public func verticalAlignTo(
    _ edge: LayoutYAxisEdge,
    of view: AnchorsProviding,
    with offset: CGFloat = 0.0,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    let constraint = centerYAnchor.constraint(equalTo: view.anchor(for: edge), constant: offset)
    constraint.priority = priority
    constraint.isActive = true
    return constraint
  }

  // MARK: - Same edge pinning

  @discardableResult
  public func pinTo(
    _ edge: LayoutEdge,
    of view: AnchorsProviding,
    with offset: CGFloat = 0.0,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    let constraint: NSLayoutConstraint
    switch edge {
    case .leading:
      constraint = leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: offset)
    case .top:
      constraint = topAnchor.constraint(equalTo: view.topAnchor, constant: offset)
    case .trailing:
      constraint = trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: offset)
    case .bottom:
      constraint = bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: offset)
    }
    constraint.priority = priority
    constraint.isActive = true
    return constraint
  }

  // MARK: - X Axis Pinning

  @discardableResult
  public func pin(
    _ edge: LayoutXAxisEdge,
    to layoutEdge: LayoutXAxisEdge,
    of view: AnchorsProviding,
    offset: CGFloat = 0.0,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    let ownAnchor = self.anchor(for: edge)
    let pinningToAnchor = view.anchor(for: layoutEdge)
    let constraint = ownAnchor.constraint(equalTo: pinningToAnchor, constant: offset)
    constraint.priority = priority
    constraint.isActive = true
    return constraint
  }

  @discardableResult
  public func pin(
    _ edge: LayoutXAxisEdge,
    greaterThanOrEqualTo layoutEdge: LayoutXAxisEdge,
    of view: AnchorsProviding,
    constant: CGFloat = 0.0,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    let ownAnchor = self.anchor(for: edge)
    let pinningToAnchor = view.anchor(for: layoutEdge)
    let constraint = ownAnchor.constraint(greaterThanOrEqualTo: pinningToAnchor, constant: constant)
    constraint.priority = priority
    constraint.isActive = true
    return constraint
  }

  @discardableResult
  public func pin(
    _ edge: LayoutXAxisEdge,
    lessThanOrEqualTo layoutEdge: LayoutXAxisEdge,
    of view: AnchorsProviding,
    constant: CGFloat = 0.0,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    let ownAnchor = self.anchor(for: edge)
    let pinningToAnchor = view.anchor(for: layoutEdge)
    let constraint = ownAnchor.constraint(lessThanOrEqualTo: pinningToAnchor, constant: constant)
    constraint.priority = priority
    constraint.isActive = true
    return constraint
  }

  // MARK: - Y Axis Pinning

  @discardableResult
  public func pin(
    _ edge: LayoutYAxisEdge,
    to layoutEdge: LayoutYAxisEdge,
    of view: AnchorsProviding,
    offset: CGFloat = 0.0,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    let ownAnchor = self.anchor(for: edge)
    let pinningToAnchor = view.anchor(for: layoutEdge)
    let constraint = ownAnchor.constraint(equalTo: pinningToAnchor, constant: offset)
    constraint.priority = priority
    constraint.isActive = true
    return constraint
  }

  @discardableResult
  public func pin(
    _ edge: LayoutYAxisEdge,
    greaterThanOrEqualTo layoutEdge: LayoutYAxisEdge,
    of view: AnchorsProviding,
    constant: CGFloat = 0.0,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    let ownAnchor = self.anchor(for: edge)
    let pinningToAnchor = view.anchor(for: layoutEdge)
    let constraint = ownAnchor.constraint(greaterThanOrEqualTo: pinningToAnchor, constant: constant)
    constraint.priority = priority
    constraint.isActive = true
    return constraint
  }

  @discardableResult
  public func pin(
    _ edge: LayoutYAxisEdge,
    lessThanOrEqualTo layoutEdge: LayoutYAxisEdge,
    of view: AnchorsProviding,
    constant: CGFloat = 0.0,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    let ownAnchor = self.anchor(for: edge)
    let pinningToAnchor = view.anchor(for: layoutEdge)
    let constraint = ownAnchor.constraint(lessThanOrEqualTo: pinningToAnchor, constant: constant)
    constraint.priority = priority
    constraint.isActive = true
    return constraint
  }

  // MARK: - Superview pinning

  @discardableResult
  public func pinToSuperviewEdge(
    _ superviewEdge: LayoutEdge,
    offset: CGFloat = 0.0,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    guard let superview = superview else {
      fatalError("Can't add constraints without superview")
    }
    return pinTo(superviewEdge, of: superview, with: offset, priority: priority)
  }

  @discardableResult
  public func pinEdge(
    _ edge: LayoutYAxisEdge,
    toSuperviewEdge superviewEdge: LayoutYAxisEdge,
    offset: CGFloat = 0.0,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    guard let superview = superview else {
      fatalError("Can't add constraints without superview")
    }
    return
      pin(edge, to: superviewEdge, of: superview, offset: offset, priority: priority)
  }

  @discardableResult
  public func pinEdge(
    _ edge: LayoutXAxisEdge,
    toSuperviewEdge superviewEdge: LayoutXAxisEdge,
    offset: CGFloat = 0.0,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    guard let superview = superview else {
      fatalError("Can't add constraints without superview")
    }
    return
      pin(edge, to: superviewEdge, of: superview, offset: offset, priority: priority)
  }

  @discardableResult
  public func pinToSuperviewSafeAreaEdge(
    _ superviewEdge: LayoutEdge,
    offset: CGFloat = 0.0,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    guard let superview = superview else {
      fatalError("Can't add constraints without superview")
    }
    return pinTo(superviewEdge, of: superview.safeAreaLayoutGuide, with: offset, priority: priority)
  }

  @discardableResult
  public func pinEdgesToSuperview(
    with insets: UIEdgeInsets = .zero,
    priorities: [LayoutEdge: UILayoutPriority] = [:]
  ) -> EdgeConstraints {
    let top =
      pinEdgeToSuperview(
        .top,
        with: insets,
        priority: priorities[.top, default: .required]
      )
    let leading =
      pinEdgeToSuperview(
        .leading,
        with: insets,
        priority: priorities[.leading, default: .required]
      )
    let bottom =
      pinEdgeToSuperview(
        .bottom,
        with: insets,
        priority: priorities[.bottom, default: .required]
      )
    let trailing =
      pinEdgeToSuperview(
        .trailing,
        with: insets,
        priority: priorities[.trailing, default: .required]
      )

    return
      EdgeConstraints(top: top, leading: leading, bottom: bottom, trailing: trailing)
  }

  @discardableResult
  public func pinToSuperviewSafeAreaEdges(
    with insets: UIEdgeInsets = .zero,
    priority: UILayoutPriority = .required
  ) -> EdgeConstraints {
    let top = pinEdgeToSuperviewSafeArea(.top, with: insets, priority: priority)
    let leading = pinEdgeToSuperviewSafeArea(.leading, with: insets, priority: priority)
    let bottom = pinEdgeToSuperviewSafeArea(.bottom, with: insets, priority: priority)
    let trailing = pinEdgeToSuperviewSafeArea(.trailing, with: insets, priority: priority)

    return
      EdgeConstraints(top: top, leading: leading, bottom: bottom, trailing: trailing)
  }

  public func pinEdgesToSuperviewSafeArea(
    excluding edge: LayoutEdge,
    with insets: UIEdgeInsets = .zero,
    priority: UILayoutPriority = .required
  ) {
    var edges = LayoutEdge.allCases
    edges.removeAll(where: { $0 == edge })
    pinEdgesToSuperviewSafeArea(edges, with: insets, priority: priority)
  }

  public func pinEdgesToSuperview(
    excluding edge: LayoutEdge,
    with insets: UIEdgeInsets = .zero
  ) {
    var edges = LayoutEdge.allCases
    edges.removeAll(where: { $0 == edge })
    pinEdgesToSuperview(edges, with: insets)
  }

  @discardableResult
  private func pinEdgeToSuperview(
    _ edge: LayoutEdge,
    with insets: UIEdgeInsets = .zero,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    let offset = insets.offset(for: edge)
    return pinToSuperviewEdge(edge, offset: offset, priority: priority)
  }

  private func pinEdgesToSuperview(
    _ edges: [LayoutEdge],
    with insets: UIEdgeInsets = .zero
  ) {
    edges.forEach {
      pinEdgeToSuperview($0, with: insets)
    }
  }

  @discardableResult
  private func pinEdgeToSuperviewSafeArea(
    _ edge: LayoutEdge,
    with insets: UIEdgeInsets = .zero,
    priority: UILayoutPriority = .required
  ) -> NSLayoutConstraint {
    let offset = insets.offset(for: edge)
    return pinToSuperviewSafeAreaEdge(edge, offset: offset, priority: priority)
  }

  private func pinEdgesToSuperviewSafeArea(
    _ edges: [LayoutEdge],
    with insets: UIEdgeInsets = .zero,
    priority: UILayoutPriority = .required
  ) {
    edges.forEach {
      pinEdgeToSuperviewSafeArea($0, with: insets, priority: priority)
    }
  }
}

// MARK: - Private extensions

extension UIEdgeInsets {
  fileprivate func offset(for edge: UIView.LayoutEdge) -> CGFloat {
    switch edge {
    case .leading: return left
    case .top: return top
    case .trailing: return -right
    case .bottom: return -bottom
    }
  }
}

extension AnchorsProviding {
  fileprivate func anchor(
    for directionalEdge: UIView.LayoutYAxisEdge
  ) -> NSLayoutYAxisAnchor {
    switch directionalEdge {
    case .top:
      return topAnchor
    case .bottom:
      return bottomAnchor
    }
  }

  fileprivate func anchor(
    for directionalEdge: UIView.LayoutXAxisEdge
  ) -> NSLayoutXAxisAnchor {
    switch directionalEdge {
    case .leading:
      return leadingAnchor
    case .trailing:
      return trailingAnchor
    }
  }
}

extension SizeAnchorProviding {
  fileprivate func anchor(for dimension: UIView.LayoutDimension) -> NSLayoutDimension {
    switch dimension {
    case .width:
      return widthAnchor
    case .height:
      return heightAnchor
    }
  }
}

extension UIButton {
  public static func newAutoLayout(type: ButtonType) -> Self {
    let button = self.init(type: type)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }
}
