//
//  GlobeView.swift
//  CardWar
//

import UIKit

/// A small hand-drawn globe shown on the menu, with a caption beneath it
/// ("West Side" / "East Side"). It renders a day or night palette automatically
/// based on the current interface style, which satisfies the "images change in
/// night mode" requirement without shipping separate image assets.
final class GlobeView: UIView {

    /// Caption under the globe.
    var title: String = "" {
        didSet { titleLabel.text = title }
    }

    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label   // adapts to light/dark automatically
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    /// Re-draw the globe when switching between light and dark mode.
    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        if traitCollection.userInterfaceStyle != previous?.userInterfaceStyle {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        let isNight = traitCollection.userInterfaceStyle == .dark

        let ocean = isNight ? UIColor(red: 0.10, green: 0.16, blue: 0.34, alpha: 1)
                            : UIColor(red: 0.20, green: 0.55, blue: 0.95, alpha: 1)
        let land  = isNight ? UIColor(red: 0.34, green: 0.44, blue: 0.66, alpha: 1)
                            : UIColor(red: 0.30, green: 0.75, blue: 0.40, alpha: 1)

        // Leave room beneath the globe for the caption.
        let captionSpace: CGFloat = 24
        let size = min(bounds.width, bounds.height - captionSpace)
        guard size > 0 else { return }

        let globeRect = CGRect(x: (bounds.width - size) / 2, y: 0, width: size, height: size)
            .insetBy(dx: 3, dy: 3)

        let circle = UIBezierPath(ovalIn: globeRect)
        ocean.setFill()
        circle.fill()

        // Clip to the globe, then drop a couple of stylised "continents".
        circle.addClip()
        land.setFill()
        UIBezierPath(ovalIn: CGRect(x: globeRect.minX + size * 0.10,
                                    y: globeRect.minY + size * 0.16,
                                    width: size * 0.42,
                                    height: size * 0.30)).fill()
        UIBezierPath(ovalIn: CGRect(x: globeRect.minX + size * 0.44,
                                    y: globeRect.minY + size * 0.48,
                                    width: size * 0.38,
                                    height: size * 0.42)).fill()
    }
}
