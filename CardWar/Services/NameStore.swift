//
//  NameStore.swift
//  CardWar
//

import Foundation

/// Tiny wrapper around `UserDefaults` for persisting the player's name between
/// launches. On the very first launch it returns `nil` (so the menu shows the
/// "Insert Name" button); afterwards it returns the saved name.
enum NameStore {
    private static let key = "player_name"

    static var name: String? {
        get { UserDefaults.standard.string(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
