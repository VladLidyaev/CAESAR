// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

class FullScreenImageViewController: UIViewController, UIScrollViewDelegate {
  private var panGestureRecognizer: UIPanGestureRecognizer!

  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    return scrollView
  }()

  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.isUserInteractionEnabled = true
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  private lazy var closeButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(Icons.close, for: .normal)
    button.tintColor = .white
    button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    return button
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
    view.addSubview(closeButton)
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
    closeButton.pinToSuperviewSafeAreaEdge(.top, offset: LocalConstants.closeButtonTrailingOffset)
    closeButton.pinToSuperviewSafeAreaEdge(.trailing, offset: -LocalConstants.closeButtonTrailingOffset)
    closeButton.setDimensions(
      to: .init(
        width: LocalConstants.closeButtonSideLength, height: LocalConstants.closeButtonSideLength
      )
    )
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
  static let closeButtonSideLength: CGFloat = 28.0
  static let closeButtonTrailingOffset: CGFloat = 20.0
}
