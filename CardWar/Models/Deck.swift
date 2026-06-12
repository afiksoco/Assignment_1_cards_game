//
//  Deck.swift
//  CardWar
//

import Foundation

/// A standard 52-card deck. Cards are drawn at random *with replacement* —
/// each round is independent, which matches the assignment where a fresh pair
/// of cards is shown every few seconds.
struct Deck {
    private static let ranks: [(symbol: String, strength: Int)] = [
        ("2", 2), ("3", 3), ("4", 4), ("5", 5), ("6", 6), ("7", 7),
        ("8", 8), ("9", 9), ("10", 10), ("J", 11), ("Q", 12), ("K", 13), ("A", 14)
    ]
    private static let suits = ["♠", "♥", "♦", "♣"]

    let cards: [PlayingCard]

    init() {
        cards = Deck.ranks.flatMap { rank in
            Deck.suits.map { suit in
                PlayingCard(rank: rank.symbol, suit: suit, strength: rank.strength)
            }
        }
    }

    /// Returns a random card from the full deck.
    func drawRandom() -> PlayingCard {
        // The deck is never empty, so force-unwrap is safe here.
        cards.randomElement()!
    }
}
