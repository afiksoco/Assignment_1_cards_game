//
//  GameEngine.swift
//  CardWar
//

import Foundation

/// The result of comparing the two cards dealt in a single round.
enum RoundOutcome {
    case userWon
    case pcWon
    case tie
}

/// Pure game logic for the card battle. It deliberately knows nothing about
/// UIKit so the rules can be reasoned about (and unit-tested) on their own.
/// The view controller drives it one round at a time and reads back the score.
final class GameEngine {
    /// Number of mini-games played before the match ends.
    let totalRounds: Int

    private(set) var currentRound = 0
    private(set) var userScore = 0
    private(set) var pcScore = 0

    /// The cards shown in the most recent round.
    private(set) var userCard: PlayingCard?
    private(set) var pcCard: PlayingCard?

    private let deck = Deck()

    init(totalRounds: Int = 10) {
        self.totalRounds = totalRounds
    }

    /// True once every round has been played.
    var isFinished: Bool { currentRound >= totalRounds }

    /// Deals a fresh pair of cards, updates the score and advances the round
    /// counter. Equal cards are ignored (no point is awarded), as required.
    @discardableResult
    func playRound() -> RoundOutcome {
        let user = deck.drawRandom()
        let pc = deck.drawRandom()
        userCard = user
        pcCard = pc
        currentRound += 1

        if user.strength > pc.strength {
            userScore += 1
            return .userWon
        } else if pc.strength > user.strength {
            pcScore += 1
            return .pcWon
        } else {
            return .tie
        }
    }

    /// The match winner's name. The house (PC) wins on a tie, per the spec.
    func winnerName(userName: String) -> String {
        userScore > pcScore ? userName : "PC"
    }

    /// The score belonging to the winning party (shown on the summary screen).
    var winningScore: Int {
        max(userScore, pcScore)
    }
}
