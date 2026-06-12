//
//  PlayerSide.swift
//  CardWar
//

import Foundation

/// Which half of the globe the player is assigned to. The side is decided on
/// the menu screen by comparing the device longitude to a fixed midpoint.
/// The raw value doubles as the on-screen label.
enum PlayerSide: String {
    case west = "West Side"
    case east = "East Side"
}
