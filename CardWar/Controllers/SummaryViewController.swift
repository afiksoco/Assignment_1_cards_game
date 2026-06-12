//
//  SummaryViewController.swift
//  CardWar
//
//  Screen 3 — the summary.
//

import UIKit

/// The summary screen. Shows the winner and their score, plus a button back to
/// the menu. A tie is decided in favour of the house (PC), per the spec.
final class SummaryViewController: UIViewController {

    // Injected by the game screen.
    var userName = "Player"
    var userScore = 0
    var pcScore = 0

    private let winnerLabel = UILabel()
    private let scoreLabel = UILabel()
    private let backButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Summary"
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true

        setupViews()
        showResult()
    }

    private func setupViews() {
        winnerLabel.font = .systemFont(ofSize: 32, weight: .bold)
        winnerLabel.textAlignment = .center
        winnerLabel.textColor = .label
        winnerLabel.numberOfLines = 0

        scoreLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = .label

        backButton.setTitle("BACK TO MENU", for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        backButton.backgroundColor = .systemBlue
        backButton.tintColor = .white
        backButton.layer.cornerRadius = 12
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [winnerLabel, scoreLabel, backButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 28
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 220),
            backButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func showResult() {
        // Tie → the house (PC) wins.
        let userWins = userScore > pcScore
        let winner = userWins ? userName : "PC"
        let winningScore = max(userScore, pcScore)
        winnerLabel.text = "Winner: \(winner)"
        scoreLabel.text = "score: \(winningScore)"
    }

    @objc private func backTapped() {
        // Pop the whole game/summary stack and return to the root menu.
        navigationController?.popToRootViewController(animated: true)
    }
}
