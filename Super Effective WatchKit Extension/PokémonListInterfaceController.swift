//
//  PokémonListInterfaceController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 11/25/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation
import PokeKit

class PokémonListRowController: NSObject {
	
	@IBOutlet var icon: WKInterfaceImage!
	@IBOutlet var nameLabel: WKInterfaceLabel!
	@IBOutlet var numberLabel: WKInterfaceLabel!
	
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

class PokémonRepresentingInterfaceController: WKInterfaceController {
	var pokémon: Pokémon!
	
	func setFavoriteMenuItem() {
		clearAllMenuItems()
		
		guard let pokémon = pokémon else {
			return
		}
		
		if favorites.contains(pokémon.id) {
			addMenuItem(with: #imageLiteral(resourceName: "unlike"), title: "Remove from Favorites", action: #selector(addOrRemoveFromFavorites))
		} else {
			addMenuItem(with: #imageLiteral(resourceName: "like"), title: "Add to Favorites", action: #selector(addOrRemoveFromFavorites))
		}
	}
	
	@objc func addOrRemoveFromFavorites() {
		if favorites.contains(pokémon.id) {
			favorites.removeAll { $0 == pokémon.id }
		} else {
			favorites.append(pokémon.id)
		}
		
		setFavoriteMenuItem()
	}
}

var favorites: [Int] {
	get {
		return (UserDefaults.standard.object(forKey: "favorites") as? [Int]) ?? []
	}
	set {
		UserDefaults.standard.setValue(newValue, forKey: "favorites")
	}
}

class PokémonListInterfaceController: WKInterfaceController {
	
	@IBOutlet var pokemonListTable: WKInterfaceTable!
	
	var isDebug: Bool = false
	
	var info = [PokémonInfo]() {
		didSet {
			loadTable()
		}
	}
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		let range = context as? PokédexRange ?? PokédexRange(dexNumbers: favorites, title: "Favorites")
		
		setTitle(range.title)
		
		isDebug = range.title.lowercased().contains("debug")
		
		info = range.dexNumbers.compactMap {
			allPokémonInfo[safe: $0]
		}
	}
	
	func loadTable() {
		pokemonListTable.setNumberOfRows(info.count, withRowType: "PokemonListRow")
		
		for index in 0 ..< info.count {
			let pokémonInfo = info[index]
			let row = pokemonListTable.rowController(at: index) as! PokémonListRowController
			
			row.nameLabel.setText(pokémonInfo.name)
			
			row.numberLabel.setText("#\(String(format: "%03d", pokémonInfo.ndex))" + (isDebug ? " (\(pokémonInfo.id))" : ""))
			
			loadImage(in: row, for: pokémonInfo)
			
		}
	}
	
	func loadImage(in row: PokémonListRowController, for info: PokémonInfo) {
		DispatchQueue.global(qos: .background).async {
			if let image = info.icon {
				DispatchQueue.main.async {
					row.icon.setImage(image)
				}
			}
		}
	}
	
//	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
//		print(#function)
//
//		guard let pokémon = Pokémon.with(id: info[rowIndex].id) else { return }
//		push(pokémon: pokémon)
//	}
	
	override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
		guard let pokémon = Pokémon.with(id: info[rowIndex].id) else { return nil }
		return pokémon
	}
	
	@IBAction func sortByNumberButtonPressed() {
		info.sort { first, second in
			if first.ndex == second.ndex {
				return first.id < second.id
			} else {
				return first.ndex < second.ndex
			}
		}
		
		loadTable()
	}
	
	@IBAction func sortByNameButtonPressed() {
		info.sort { first, second in
			return first.name < second.name
		}
		loadTable()
	}
	
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
	}
	
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	
}
