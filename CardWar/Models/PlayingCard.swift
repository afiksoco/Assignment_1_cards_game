//
//  PlayingCard.swift
//  CardWar
//

import Foundation

/// A single playing card. `strength` is the only thing the game compares each
/// round (2 = weakest … 14 = Ace). `isRed` is used purely for text colour.
struct PlayingCard {
    let rank: String   // "2"… "10", "J", "Q", "K", "A"
    let suit: String   // "♠", "♥", "♦", "♣"
    let strength: Int  // 2…14

    /// Hearts and diamonds are drawn red, clubs and spades are drawn dark.
    var isRed: Bool { suit == "♥" || suit == "♦" }
}
