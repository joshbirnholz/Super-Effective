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
	func present(pokémon: Pokémon) {
		var namesAndContexts = [(name: String, context: AnyObject)]()
		
		namesAndContexts.append(("MoreInfo", pokémon as AnyObject))
		namesAndContexts.append(("PokemonDetail", pokémon as AnyObject))
		namesAndContexts.append(("Moveset", pokémon as AnyObject))
		namesAndContexts.append(("Abilities", pokémon as AnyObject))
		namesAndContexts.append(("BaseStats", pokémon as AnyObject))
		namesAndContexts.append(("Evo", [self, pokémon] as AnyObject))
		
		updateRecents(withID: pokémon.id)
		
		presentController(withNamesAndContexts: namesAndContexts)
	}
}

var favorites: [Int] {
	return (UserDefaults.standard.object(forKey: "favorites") as? [Int])?.sorted(by: <) ?? []
}

class PokémonListInterfaceController: WKInterfaceController {
	
	@IBOutlet var pokemonListTable: WKInterfaceTable!
	
	var info = [PokémonInfo]() {
		didSet {
			loadTable()
		}
	}
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		let range = context as? PokédexRange ?? PokédexRange(dexNumbers: favorites, title: "Favorites")
		
		setTitle(range.title)
		
		info = range.dexNumbers.flatMap {
			allPokémonInfo[$0]
		}
	}
	
	func loadTable() {
		pokemonListTable.setNumberOfRows(info.count, withRowType: "PokemonListRow")
		
		for index in 0 ..< info.count {
			let pokémonInfo = info[index]
			let row = pokemonListTable.rowController(at: index) as! PokémonListRowController
			
			row.nameLabel.setText(pokémonInfo.name)
			
			row.numberLabel.setText("#\(String(format: "%03d", pokémonInfo.ndex))")
			
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
	
	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		print(#function)
		
		guard let pokémon = Pokémon.with(id: info[rowIndex].id) else { return }
		present(pokémon: pokémon)
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
