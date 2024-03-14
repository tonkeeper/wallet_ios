//
//  ServiceCellContentView.swift
//  Tonkeeper
//
//  Created by Grigory on 9.6.23..
//

import UIKit

final class ServiceCellContentView: UIControlClosure, ContainerCollectionViewCellContent {
  
  weak var imageLoader: ImageLoader?
  
  private let titleLabel = UILabel()
  private let descriptionLabel = UILabel()
  private let tokenContainer: UIView = {
    let view = UIView()
    view.backgroundColor = .Background.contentTint
    view.layer.cornerRadius = .tokenCornerRadius
    view.isUserInteractionEnabled = false
    return view
  }()
  private let tokenLabel = UILabel()
  private let chevronImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .Icons.Service.chevron
    imageView.tintColor = .Icon.tertiary
    imageView.isUserInteractionEnabled = false
    return imageView
  }()
  private let logoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .center
    imageView.layer.cornerRadius = .logoCornerRadius
    imageView.layer.masksToBounds = true
    imageView.isUserInteractionEnabled = false
    return imageView
  }()
  private let textContainer: UIView = {
    let view = UIView()
    view.isUserInteractionEnabled = false
    return view
  }()
  
  override var isHighlighted: Bool {
    didSet {
      guard isHighlighted != oldValue else { return }
      didUpdateHightlightState()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let width = bounds.width - UIEdgeInsets.contentPadding.left - UIEdgeInsets.contentPadding.right
    
    logoImageView.frame = .init(
      x: UIEdgeInsets.contentPadding.left,
      y: bounds.height/2 - .logoSide/2,
      width: .logoSide,
      height: .logoSide
    )
    
    chevronImageView.frame = .init(
      x: bounds.width - UIEdgeInsets.contentPadding.right - .chevronWidth,
      y: bounds.height/2 - .chevronHeight/2,
      width: .chevronWidth,
      height: .chevronHeight
    )
    
    let textWidth = width - .logoRightSpace - logoImageView.frame.maxX - chevronImageView.frame.width - .chevronLeftSpace
    
    let tokenLabelSize = tokenLabel.sizeThatFits(.init(width: textWidth, height: 0))
    let tokenWidth = tokenLabelSize.width + UIEdgeInsets.tokenLabelPadding.left + UIEdgeInsets.tokenLabelPadding.right
    let tokenHeight = tokenLabelSize.height + UIEdgeInsets.tokenLabelPadding.bottom + UIEdgeInsets.tokenLabelPadding.top
    
    
    let titleWidth = textWidth - tokenWidth
    let titleLabelSize = titleLabel.sizeThatFits(.init(width: titleWidth, height: 0))
    
    let descriptionLabelSize = descriptionLabel.sizeThatFits(.init(width: textWidth, height: 0))
    
    let textContainerHeight = titleLabelSize.height + descriptionLabelSize.height
    
    textContainer.frame = .init(x: logoImageView.frame.maxX + .logoRightSpace,
                                y: bounds.height/2 - textContainerHeight/2,
                                width: textWidth,
                                height: textContainerHeight)
    
    titleLabel.frame = .init(x: 0,
                             y: 0,
                             width: titleLabelSize.width,
                             height: titleLabelSize.height)
    
    descriptionLabel.frame = .init(x: 0,
                                   y: titleLabel.frame.maxY,
                                   width: descriptionLabelSize.width,
                                   height: descriptionLabelSize.height)
    
    tokenContainer.frame = .init(x: titleLabel.frame.maxX + .tokenLeftSpace,
                                 y: titleLabel.frame.maxY - tokenHeight,
                                 width: tokenWidth, height: tokenHeight)
    
    tokenLabel.frame = .init(x: UIEdgeInsets.tokenLabelPadding.left,
                             y: UIEdgeInsets.tokenLabelPadding.top,
                             width: tokenLabelSize.width,
                             height: tokenLabelSize.height)
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    var contentSize = size
    contentSize.width -= UIEdgeInsets.contentPadding.left + UIEdgeInsets.contentPadding.right
    
    let textWidth = contentSize.width - .logoSide - .logoRightSpace - .chevronWidth - .chevronLeftSpace
    let tokenLabelSize = tokenLabel.sizeThatFits(.init(width: textWidth, height: 0))
    let tokenWidth = tokenLabelSize.width + UIEdgeInsets.tokenLabelPadding.left + UIEdgeInsets.tokenLabelPadding.right
    
    let titleWidth = textWidth - tokenWidth - .tokenLeftSpace
    let titleLabelSize = titleLabel.sizeThatFits(.init(width: titleWidth, height: 0))
    
    let descriptionLabelSize = descriptionLabel.sizeThatFits(.init(width: textWidth, height: 0))
    
    let textHeight = titleLabelSize.height + descriptionLabelSize.height
    let heigth = max(textHeight, .logoSide)
    return .init(
      width: size.width,
      height: heigth + UIEdgeInsets.contentPadding.top + UIEdgeInsets.contentPadding.bottom
    )
  }
  
  func configure(model: Model) {
    switch model.logo {
    case let .image(image, tinColor, backgroundColor):
      logoImageView.image = image
      logoImageView.tintColor = tinColor
      logoImageView.backgroundColor = backgroundColor
    case let .url(url):
      imageLoader?.loadImage(imageURL: url, imageView: logoImageView, size: .init(width: .logoSide, height: .logoSide))
    }
    titleLabel.attributedText = model.title
    descriptionLabel.attributedText = model.description
    tokenLabel.attributedText = model.token
    tokenContainer.isHidden = model.token == nil
    setNeedsLayout()
  }
  
  func prepareForReuse() {
    logoImageView.image = nil
    titleLabel.attributedText = nil
    descriptionLabel.attributedText = nil
    tokenLabel.attributedText = nil
  }
}

private extension ServiceCellContentView {
  func setup() {
    descriptionLabel.numberOfLines = 0
    
    addSubview(textContainer)
    addSubview(chevronImageView)
    addSubview(logoImageView)
    
    textContainer.addSubview(tokenContainer)
    textContainer.addSubview(titleLabel)
    textContainer.addSubview(descriptionLabel)
    
    tokenContainer.addSubview(tokenLabel)
  }
  
  func didUpdateHightlightState() {
    let duration: TimeInterval = isHighlighted ? 0.05 : 0.2
    
    UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction, .curveEaseInOut]) {
      self.backgroundColor = self.isHighlighted ? .Background.highlighted : .clear
    }
  }
}

private extension CGFloat {
  static let logoSide: CGFloat = 44
  static let logoRightSpace: CGFloat = 16
  static let logoVerticalSpace: CGFloat = 10
  static let logoCornerRadius: CGFloat = 12
  static let chevronHeight: CGFloat = 16
  static let chevronWidth: CGFloat = 16
  static let chevronLeftSpace: CGFloat = 16
  static let tokenLeftSpace: CGFloat = 6
  static let tokenCornerRadius: CGFloat = 4
}

private extension UIEdgeInsets {
  static let tokenLabelPadding: UIEdgeInsets = .init(top: 2.5, left: 5, bottom: 3.5, right: 5)
  static let contentPadding: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
}
