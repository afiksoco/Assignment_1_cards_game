//
//  CardView.swift
//  CardWar
//

import UIKit

/// Displays a single playing card with a flip animation. All colours come from
/// dynamic system colours (`.label`, `.systemRed`, `.secondarySystemBackground`)
/// so the card looks correct in both light and dark mode automatically.
final class CardView: UIView {

    private let rankLabel = UILabel()
    private let suitLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 14
        layer.borderWidth = 2
        layer.borderColor = UIColor.separator.cgColor

        rankLabel.font = .systemFont(ofSize: 52, weight: .bold)
        rankLabel.textAlignment = .center
        suitLabel.font = .systemFont(ofSize: 44, weight: .bold)
        suitLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [rankLabel, suitLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        showFaceDown()
    }

    /// `cgColor` doesn't auto-update on appearance changes, so refresh it here.
    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        layer.borderColor = UIColor.separator.cgColor
    }

    /// Flip the card over to reveal a value.
    func reveal(card: PlayingCard) {
        UIView.transition(with: self, duration: 0.35, options: .transitionFlipFromLeft) {
            self.rankLabel.text = card.rank
            self.suitLabel.text = card.suit
            let color: UIColor = card.isRed ? .systemRed : .label
            self.rankLabel.textColor = color
            self.suitLabel.textColor = color
        }
    }

    /// Flip the card face-down (between rounds).
    func flipFaceDown() {
        UIView.transition(with: self, duration: 0.35, options: .transitionFlipFromRight) {
            self.showFaceDown()
        }
    }

    private func showFaceDown() {
        rankLabel.text = "🂠"
        rankLabel.textColor = .label
        suitLabel.text = ""
    }
}
