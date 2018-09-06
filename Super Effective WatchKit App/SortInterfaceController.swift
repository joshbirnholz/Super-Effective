//
//  SortInterfaceController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 11/25/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation
import PokeKit

var recents: [Int] {
get {
	return UserDefaults.standard.object(forKey: "recents") as? [Int] ?? []
}
set {
	UserDefaults.standard.set(newValue, forKey: "recents")
}
}

func updateRecents(withID id: Int) {
	if let index = recents.index(of: id) {
		recents.remove(at: index)
	} else if recents.count >= 20 {
		recents.removeLast()
	}
	recents.insert(id, at: 0)
}

var recentsRange: PokédexRange {
	return PokédexRange(dexNumbers: recents, title: "Recents")
}

class SimpleRowController: NSObject {
	@IBOutlet var label: WKInterfaceLabel!
}

class SortInterfaceController: WKInterfaceController {
	
	@IBOutlet var buttonsTable: WKInterfaceTable!
	
	let generationRanges: [PokédexRange] = [PokédexRange(dexNumbers: Array(000 ... 150), title: "Gen I"),
	                                         PokédexRange(dexNumbers: Array(151 ... 250), title: "Gen II"),
	                                         PokédexRange(dexNumbers: Array(251 ... 385), title: "Gen III"),
	                                         PokédexRange(dexNumbers: Array(386 ... 492), title: "Gen IV"),
	                                         PokédexRange(dexNumbers: Array(493 ... 648), title: "Gen V"),
	                                         PokédexRange(dexNumbers: Array(649 ... 720), title: "Gen VI"),
	                                         PokédexRange(dexNumbers: Array(721 ... 801), title: "Gen VII"),
//											 PokédexRange(dexNumbers: Array(allPokémonInfo.indices), title: "Debug — All")
	]

	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
		buttonsTable.setNumberOfRows(generationRanges.count, withRowType: "SimpleRow")
		
		for index in 0 ..< buttonsTable.numberOfRows {
			
			let row = buttonsTable.rowController(at: index) as! SimpleRowController
			
			row.label.setText(generationRanges[index].title)
			
		}
	}

	@IBAction func searchButtonPressed() {
		let note = "Note: Dictation may be unreliable with Pokémon names."
		presentTextInputController(withSuggestions: [note], allowedInputMode: .plain) { results in
			guard let text = results?.first as? String,
			text != "" && text != note else {
				return
			}
			
			let range = self.search(query: text)
			
			if range.dexNumbers.count == 1 {
				guard let first = range.dexNumbers.first,
					let pokémon = Pokémon.with(id: allPokémonInfo[first].id) else {
						return
				}
				self.push(pokémon: pokémon)
			} else {
				self.pushController(withName: "PokedexList", context: range)
			}
			
		}
	}
	
	@IBAction func favoritesButtonPressed() {
		guard !favorites.isEmpty else {
			let okAction = WKAlertAction(title: "OK", style: .default, handler: { })
			presentAlert(withTitle: "You haven't added any favorites!", message: "Press firmly on the screen while viewing a Pokémon's info to add it to your list of favorites.", preferredStyle: .alert, actions: [okAction])
			
			return
		}
		
		let range = PokédexRange(dexNumbers: favorites, title: "Favorites")
		
		self.pushController(withName: "PokedexList", context: range)
	}
	
	@IBAction func recentsButtonPressed() {
		pushController(withName: "PokedexList", context: recentsRange)
	}
	
	func search(query: String) -> PokédexRange {
		let query = query.lowercased().capitalized
		let nums = allPokémonInfo.filter {
			$0.id <= 802 && $0.name.hasPrefix(query)
			}.sorted { first, second in
				first.name < second.name
			}.map {
				$0.id
		}
		
		return PokédexRange(dexNumbers: nums, title: "\(nums.count) \("Result".pluralize(count: nums.count))")
	}
	
	override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
		if segueIdentifier == "ShowList" {
			return generationRanges[rowIndex]
		}
		
		return nil
	}
	
}
