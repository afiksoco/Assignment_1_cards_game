//
//  MenuViewController.swift
//  CardWar
//
//  Screen 1 — the menu.
//

import UIKit

/// The menu screen. It is responsible for two things:
///   1. The player's name (shown as "Hi <name>", persisted via `NameStore`).
///   2. Resolving the player's side from the device location on every launch.
///
/// The START button only becomes available once *both* a name and a side are
/// known — the game cannot run without them.
final class MenuViewController: UIViewController {

    private let locationService = LocationService()
    private var side: PlayerSide?

    // MARK: UI

    private let greetingLabel = UILabel()
    private let nameButton = UIButton(type: .system)
    private let westGlobe = GlobeView()
    private let eastGlobe = GlobeView()
    private let sideLabel = UILabel()
    private let statusLabel = UILabel()
    private let startButton = UIButton(type: .system)

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Card War"
        view.backgroundColor = .systemBackground

        setupViews()
        configureLocationCallbacks()
        refreshUI()

        // Sample the location on every launch, as required by the spec.
        locationService.requestLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // When returning from the game we may have a fresh name to show.
        refreshUI()
    }

    // MARK: Setup

    private func setupViews() {
        greetingLabel.font = .systemFont(ofSize: 32, weight: .bold)
        greetingLabel.textAlignment = .center
        greetingLabel.numberOfLines = 0

        configure(button: nameButton, title: "Insert Name", color: .systemBlue)
        nameButton.addTarget(self, action: #selector(nameTapped), for: .touchUpInside)

        westGlobe.title = PlayerSide.west.rawValue
        eastGlobe.title = PlayerSide.east.rawValue
        westGlobe.translatesAutoresizingMaskIntoConstraints = false
        eastGlobe.translatesAutoresizingMaskIntoConstraints = false

        let globeRow = UIStackView(arrangedSubviews: [westGlobe, eastGlobe])
        globeRow.axis = .horizontal
        globeRow.distribution = .fillEqually
        globeRow.spacing = 24

        sideLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        sideLabel.textAlignment = .center

        statusLabel.font = .systemFont(ofSize: 15)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0

        configure(button: startButton, title: "START", color: .systemGreen)
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            nameButton, greetingLabel, globeRow, sideLabel, statusLabel, startButton
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 22
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),

            globeRow.widthAnchor.constraint(equalTo: stack.widthAnchor),
            westGlobe.heightAnchor.constraint(equalToConstant: 140),
            eastGlobe.heightAnchor.constraint(equalToConstant: 140),

            nameButton.widthAnchor.constraint(equalToConstant: 200),
            nameButton.heightAnchor.constraint(equalToConstant: 52),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func configure(button: UIButton, title: String, color: UIColor) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        button.backgroundColor = color
        button.tintColor = .white
        button.layer.cornerRadius = 12
    }

    private func configureLocationCallbacks() {
        locationService.onSideResolved = { [weak self] side in
            self?.side = side
            self?.refreshUI()
        }
        locationService.onDenied = { [weak self] in
            self?.side = nil
            self?.statusLabel.text = "Location is required. Enable it in Settings, "
                + "or set a simulated location in the Simulator."
        }
    }

    // MARK: UI state

    /// Single place that maps the current state (name?, side?) onto the views.
    private func refreshUI() {
        let name = NameStore.name

        // Name area: button before a name exists, greeting afterwards.
        greetingLabel.isHidden = (name == nil)
        nameButton.isHidden = (name != nil)
        if let name { greetingLabel.text = "Hi \(name)" }

        // Side area: highlight only the resolved side once we have one.
        if let side {
            sideLabel.text = "You play: \(side.rawValue)"
            sideLabel.isHidden = false
            westGlobe.alpha = (side == .west) ? 1.0 : 0.25
            eastGlobe.alpha = (side == .east) ? 1.0 : 0.25
        } else {
            sideLabel.isHidden = true
            westGlobe.alpha = 1.0
            eastGlobe.alpha = 1.0
        }

        // START is only available with both a name and a side.
        let canStart = (name != nil) && (side != nil)
        startButton.isHidden = !canStart
        startButton.isEnabled = canStart

        if name == nil {
            statusLabel.text = "Tap Insert Name to begin."
        } else if side == nil {
            statusLabel.text = "Finding your side…"
        } else {
            statusLabel.text = "Ready to play!"
        }
    }

    // MARK: Actions

    @objc private func nameTapped() {
        let alert = UIAlertController(title: "Enter your name",
                                      message: "Your name is saved for next time.",
                                      preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Name"; $0.autocapitalizationType = .words }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            let text = alert?.textFields?.first?.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !text.isEmpty else { return }
            NameStore.name = text
            self?.refreshUI()
        })
        present(alert, animated: true)
    }

    @objc private func startTapped() {
        guard let name = NameStore.name, let side else { return }

        guard let game = storyboard?
            .instantiateViewController(withIdentifier: "GameViewController") as? GameViewController else {
            return
        }
        game.userName = name
        game.userSide = side
        navigationController?.pushViewController(game, animated: true)
    }
}
