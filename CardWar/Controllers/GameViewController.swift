//
//  GameViewController.swift
//  CardWar
//
//  Screen 2 — the card battle.
//

import UIKit

/// The game screen. It auto-starts when shown (there are no buttons) and runs
/// 10 rounds. Each round is a 5-second cycle:
///   • at 5s the cards flip face-up and the score updates,
///   • they stay visible for 3 seconds (counts 5 → 4 → 3),
///   • at 2s they flip face-down,
///   • at 0s the next round begins.
/// After 10 rounds it pushes the summary screen.
///
/// The clock honours the controller life cycle: it stops when the screen is
/// left or the app is backgrounded, and resumes when the app returns.
final class GameViewController: UIViewController {

    // Injected by the menu.
    var userName = "Player"
    var userSide: PlayerSide = .west

    // MARK: Game state

    private let engine = GameEngine(totalRounds: 10)

    private let cycleLength = 5     // seconds per round
    private let flipDownAt = 2      // flip face-down when the count reaches this
    private var secondsLeft = 5
    private var timer: Timer?

    // MARK: UI

    private let userNameLabel = UILabel()
    private let userScoreLabel = UILabel()
    private let pcNameLabel = UILabel()
    private let pcScoreLabel = UILabel()
    private let timerLabel = UILabel()
    private let userCardView = CardView()
    private let pcCardView = CardView()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Game"
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true   // the game runs to completion

        setupViews()
        updateScoreLabels()
        registerLifecycleObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start the match the first time the screen appears.
        if engine.currentRound == 0 {
            SoundManager.shared.startBackgroundMusic()
            startNextRound()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Leaving the screen: stop the clock and the music.
        stopTimer()
        SoundManager.shared.stopBackgroundMusic()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: App background / foreground

    private func registerLifecycleObservers() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(appWillResignActive),
                           name: UIApplication.willResignActiveNotification, object: nil)
        center.addObserver(self, selector: #selector(appDidBecomeActive),
                           name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    /// Pause the clock + music when the app goes to the background.
    @objc private func appWillResignActive() {
        stopTimer()
        SoundManager.shared.pauseBackgroundMusic()
    }

    /// Resume where we left off when the app comes back (if still playing and
    /// this screen is the visible one).
    @objc private func appDidBecomeActive() {
        guard isViewLoaded, view.window != nil, !engine.isFinished else { return }
        SoundManager.shared.resumeBackgroundMusic()
        if timer == nil { startTimer() }
    }

    // MARK: Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    /// Begins a round: deal + reveal cards, score, then run the countdown.
    private func startNextRound() {
        secondsLeft = cycleLength
        engine.playRound()               // deals cards + updates the score
        if let card = engine.userCard { userCardView.reveal(card: card) }
        if let card = engine.pcCard { pcCardView.reveal(card: card) }
        SoundManager.shared.playFlip()
        updateScoreLabels()
        updateTimerLabel()
        stopTimer()
        startTimer()
    }

    /// Called once per second by the timer.
    private func tick() {
        secondsLeft -= 1
        updateTimerLabel()

        if secondsLeft == flipDownAt {
            // Cards have been visible for 3 seconds — flip them back.
            userCardView.flipFaceDown()
            pcCardView.flipFaceDown()
        } else if secondsLeft <= 0 {
            if engine.isFinished {
                endGame()
            } else {
                startNextRound()
            }
        }
    }

    private func endGame() {
        stopTimer()
        SoundManager.shared.stopBackgroundMusic()
        SoundManager.shared.playWin()

        guard let summary = storyboard?
            .instantiateViewController(withIdentifier: "SummaryViewController") as? SummaryViewController else {
            return
        }
        summary.userName = userName
        summary.userScore = engine.userScore
        summary.pcScore = engine.pcScore
        navigationController?.pushViewController(summary, animated: true)
    }

    // MARK: Labels

    private func updateScoreLabels() {
        userNameLabel.text = userName
        userScoreLabel.text = "\(engine.userScore)"
        pcNameLabel.text = "PC"
        pcScoreLabel.text = "\(engine.pcScore)"
    }

    private func updateTimerLabel() {
        timerLabel.text = "\(max(secondsLeft, 0))"
    }

    // MARK: Setup

    private func setupViews() {
        // Two corner score blocks (name on top, big score below).
        let userBlock = scoreBlock(nameLabel: userNameLabel, scoreLabel: userScoreLabel)
        let pcBlock = scoreBlock(nameLabel: pcNameLabel, scoreLabel: pcScoreLabel)

        // Place each player on their geographic side (west = left, east = right).
        let leftBlock = userSide == .west ? userBlock : pcBlock
        let rightBlock = userSide == .west ? pcBlock : userBlock

        let topBar = UIStackView(arrangedSubviews: [leftBlock, UIView(), rightBlock])
        topBar.axis = .horizontal
        topBar.alignment = .top
        topBar.distribution = .fill
        topBar.translatesAutoresizingMaskIntoConstraints = false

        // Center timer (icon + countdown number).
        let timerIcon = UIImageView(image: UIImage(systemName: "timer"))
        timerIcon.tintColor = .systemBlue
        timerIcon.contentMode = .scaleAspectFit
        timerIcon.translatesAutoresizingMaskIntoConstraints = false

        timerLabel.font = .monospacedDigitSystemFont(ofSize: 30, weight: .bold)
        timerLabel.textColor = .systemBlue
        timerLabel.textAlignment = .center

        let timerStack = UIStackView(arrangedSubviews: [timerIcon, timerLabel])
        timerStack.axis = .vertical
        timerStack.alignment = .center
        timerStack.spacing = 4

        // Cards row, again ordered by side.
        let leftCard = userSide == .west ? userCardView : pcCardView
        let rightCard = userSide == .west ? pcCardView : userCardView
        userCardView.translatesAutoresizingMaskIntoConstraints = false
        pcCardView.translatesAutoresizingMaskIntoConstraints = false

        let cardsRow = UIStackView(arrangedSubviews: [leftCard, timerStack, rightCard])
        cardsRow.axis = .horizontal
        cardsRow.alignment = .center
        cardsRow.distribution = .equalCentering
        cardsRow.spacing = 12
        cardsRow.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(topBar)
        view.addSubview(cardsRow)

        NSLayoutConstraint.activate([
            topBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            topBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),

            cardsRow.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cardsRow.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            cardsRow.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),

            timerIcon.widthAnchor.constraint(equalToConstant: 34),
            timerIcon.heightAnchor.constraint(equalToConstant: 34),

            userCardView.widthAnchor.constraint(equalToConstant: 120),
            userCardView.heightAnchor.constraint(equalToConstant: 180),
            pcCardView.widthAnchor.constraint(equalToConstant: 120),
            pcCardView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }

    private func scoreBlock(nameLabel: UILabel, scoreLabel: UILabel) -> UIStackView {
        nameLabel.font = .systemFont(ofSize: 18, weight: .regular)
        nameLabel.textColor = .label
        scoreLabel.font = .systemFont(ofSize: 30, weight: .bold)
        scoreLabel.textColor = .label

        let stack = UIStackView(arrangedSubviews: [nameLabel, scoreLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        return stack
    }
}
