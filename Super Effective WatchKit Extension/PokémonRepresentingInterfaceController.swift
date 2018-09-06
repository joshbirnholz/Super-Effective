//
//  PokémonRepresentingInterfaceController.swift
//  Super Effective WatchKit Extension
//
//  Created by Josh Birnholz on 9/6/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation
import PokeKit

class PokémonRepresentingInterfaceController: WKInterfaceController {
	
	var pokémon: Pokémon! {
		didSet {
			setMenuItems()
		}
	}
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		setMenuItems()
	}
	
	func setMenuItems() {
		clearAllMenuItems()
		
		guard let pokémon = pokémon else {
			return
		}
		
		if favorites.contains(pokémon.id) {
			addMenuItem(with: #imageLiteral(resourceName: "unlike"), title: "Remove from Favorites", action: #selector(addOrRemoveFromFavorites))
		} else {
			addMenuItem(with: #imageLiteral(resourceName: "like"), title: "Add to Favorites", action: #selector(addOrRemoveFromFavorites))
		}
		
		addMenuItem(with: .resume, title: "Home", action: #selector(popToRoot))
	}
	
	@objc func popToRoot() {
		popToRootController()
	}
	
	@objc func addOrRemoveFromFavorites() {
		if favorites.contains(pokémon.id) {
			favorites.removeAll { $0 == pokémon.id }
		} else {
			favorites.append(pokémon.id)
		}
		
		setMenuItems()
	}
	
	override func didAppear() {
		super.didAppear()
		invalidateUserActivity()
		
		guard let activity = pokémon?.userActivity else {
			return
		}
		
		if #available(watchOSApplicationExtension 5.0, *) {
			update(activity)
			activity.becomeCurrent()
		} else {
			updateUserActivity(activity.activityType, userInfo: activity.userInfo, webpageURL: activity.webpageURL)
		}
		
	}

}

extension WKInterfaceController {
	
	func push(pokémon: Pokémon) {
		pushController(withName: "Links", context: pokémon)
	}
	
	func present(pokémon: Pokémon) {
		//		var namesAndContexts = [(name: String, context: AnyObject)]()
		//
		//		namesAndContexts.append(("MoreInfo", pokémon as AnyObject))
		//		namesAndContexts.append(("PokemonDetail", [pokémon.name, pokémon.type] as AnyObject))
		//		namesAndContexts.append(("Moveset", pokémon as AnyObject))
		//		namesAndContexts.append(("Abilities", pokémon as AnyObject))
		//		namesAndContexts.append(("BaseStats", pokémon as AnyObject))
		//		namesAndContexts.append(("Evo", [self, pokémon] as AnyObject))
		//
		//		updateRecents(withID: pokémon.id)
		//
		//		presentController(withNamesAndContexts: namesAndContexts)
		presentController(withName: "Links", context: pokémon)
	}
	
}
