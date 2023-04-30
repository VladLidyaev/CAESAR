// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

class FullScreenImageViewController: UIViewController, UIScrollViewDelegate {
  private var panGestureRecognizer: UIPanGestureRecognizer!

  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView().autoLayout()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    return scrollView
  }()

  private lazy var imageView: UIImageView = {
    let imageView = UIImageView().autoLayout()
    imageView.isUserInteractionEnabled = true
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  private lazy var closeButton: UIButton = {
    let image = Icons.close.withRenderingMode(.alwaysTemplate)
    let button = UIButton().autoLayout()
    button.setImage(image, for: .normal)
    button.tintColor = Colors.textAndIcons
    button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    return button
  }()

  private lazy var closeButtonContainer: UIView = {
    let view = UIView().autoLayout()
    view.backgroundColor = Colors.background.withAlphaComponent(LocalConstants.alphaComponent)
    view.layer.borderColor = Colors.textAndIcons.cgColor
    view.layer.borderWidth = LocalConstants.borderWidth
    view.layer.cornerRadius = LocalConstants.cornerRadius
    return view
  }()

  var image: UIImage?

  override func viewDidLoad() {
    super.viewDidLoad()

    setupViews()
    setupConstraints()

    scrollView.delegate = self
    scrollView.minimumZoomScale = LocalConstants.scrollViewMinimumZoomScale
    scrollView.maximumZoomScale = LocalConstants.scrollViewMaximumZoomScale

    imageView.image = image
    panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    imageView.addGestureRecognizer(panGestureRecognizer)
  }

  private func setupViews() {
    view.backgroundColor = .black
    view.addSubview(scrollView)
    scrollView.addSubview(imageView)
    view.addSubview(closeButtonContainer)
    closeButtonContainer.addSubview(closeButton)
  }

  private func setupConstraints() {
    // ScrollView
    scrollView.pinEdgesToSuperview()

    // ImageView
    imageView.alignToAxis(.vertical, of: scrollView)
    imageView.alignToAxis(.horizontal, of: scrollView)
    imageView.setDimension(.width, equalTo: .width, of: scrollView)
    imageView.setDimension(.height, equalTo: .height, of: scrollView)

    // CloseButton
    closeButton.setDimensions(
      to: .init(
        width: LocalConstants.closeButtonSideLength,
        height: LocalConstants.closeButtonSideLength
      )
    )
    closeButton.pinToSuperviewEdge(.top, offset: LocalConstants.closeButtonVerticalOffset)
    closeButton.pinToSuperviewEdge(.trailing, offset: -LocalConstants.closeButtonVerticalOffset)
    closeButton.pinToSuperviewEdge(.bottom, offset: -LocalConstants.closeButtonVerticalOffset)
    closeButton.pinToSuperviewEdge(.leading, offset: LocalConstants.closeButtonVerticalOffset)

    // CloseButtonContainer
    closeButtonContainer.pinToSuperviewSafeAreaEdge(.top, offset: LocalConstants.closeButtonOffset)
    closeButtonContainer.pinToSuperviewSafeAreaEdge(.trailing, offset: -LocalConstants.closeButtonOffset)
  }

  @objc func closeButtonTapped() {
    dismiss(animated: true, completion: nil)
  }

  @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    guard scrollView.zoomScale == .one else { return }

    let translation = gesture.translation(in: imageView)
    imageView.transform = CGAffineTransform(translationX: .zero, y: translation.y)

    if gesture.state == .ended {
      if abs(translation.y) > 100 {
        dismiss(animated: true, completion: nil)
      } else {
        UIView.animate(withDuration: Constants.Animation.default) {
          self.imageView.transform = .identity
        }
      }
    }
  }

  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }

  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    panGestureRecognizer.isEnabled = scrollView.zoomScale == .zero
  }
}

// MARK: - LocalConstants

private enum LocalConstants {
  static let scrollViewMinimumZoomScale: CGFloat = 1.0
  static let scrollViewMaximumZoomScale: CGFloat = 6.0
  static let alphaComponent: CGFloat = 0.6
  static let borderWidth: CGFloat = 2
  static let cornerRadius: CGFloat = 22.0
  static let closeButtonVerticalOffset: CGFloat = 8.0
  static let closeButtonOffset: CGFloat = 12.0
  static let closeButtonSideLength: CGFloat = 28.0
  static let closeButtonTrailingOffset: CGFloat = 20.0
}
