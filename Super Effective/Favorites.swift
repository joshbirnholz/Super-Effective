//
//  Favorites.swift
//  Super Effective
//
//  Created by Josh Birnholz on 9/27/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import Foundation
import PokeKit_iOS
import Intents

fileprivate var favorites: [Int] {
	get {
		return (UserDefaults.group.object(forKey: "favorites") as? [Int]) ?? []
	}
	set {
		UserDefaults.group.setValue(newValue, forKey: "favorites")
	}
}

@available(iOS 12.0, *)
fileprivate func setRelevantShortcutsForFavorites() {
	let relevantShortcuts: [INRelevantShortcut] = favorites.compactMap {
		if let userActivity = Pokémon.with(id: $0)?.userActivity {
			let shortcut = INShortcut(userActivity: userActivity)
			let relevantShortcut = INRelevantShortcut(shortcut: shortcut)
			relevantShortcut.shortcutRole = INRelevantShortcutRole.information
			return relevantShortcut
		}
		return nil
	}
	INRelevantShortcutStore.default.setRelevantShortcuts(relevantShortcuts)
}

func addToFavorites(_ newValue: Int) {
	favorites.removeAll { $0 == newValue }
	favorites.append(newValue)
	
	if #available(iOS 12.0, *) {
		setRelevantShortcutsForFavorites()
	}
}

func removeFromFavorites(_ value: Int) {
	favorites.removeAll { $0 == value }
	
	if #available(iOS 12.0, *) {
		setRelevantShortcutsForFavorites()
	}
}

var favoritesRange: PokédexRange {
	return PokédexRange(dexNumbers: favorites, title: "Favorites")
}

/// - Returns: `true` if the id was added to the favorites list, or false if it was removed.
@discardableResult func addOrRemoveFromFavorites(_ value: Int) -> Bool {
	if favorites.contains(value) {
		removeFromFavorites(value)
		return false
	} else {
		addToFavorites(value)
		return true
	}
}
