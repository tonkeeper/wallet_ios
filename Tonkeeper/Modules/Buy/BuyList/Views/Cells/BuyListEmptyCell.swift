import UIKit

final class BuyListEmptyCell: UICollectionViewCell, Reusable, ConfigurableView {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
 
    let label = UILabel()
    label.applyTextStyleFont(.label1)
    label.textColor = .Text.primary
    label.numberOfLines = 0
    label.textAlignment = .center
    label.text = "Not available in your region."
    
    contentView.addSubview(label)
    
    label.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: contentView.topAnchor),
      label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 32),
      label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      label.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -32)
    ])
  }
  
  struct Model: Hashable {}
  func configure(model: Model) {}
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
