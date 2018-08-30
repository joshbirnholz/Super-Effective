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

class SortInterfaceController: WKInterfaceController {

	@IBOutlet var generationPicker: WKInterfacePicker!
	
	let generationRanges: [PokédexRange] = [PokédexRange(dexNumbers: Array(000 ... 150), title: "Gen. I"),
	                                         PokédexRange(dexNumbers: Array(151 ... 250), title: "Gen. II"),
	                                         PokédexRange(dexNumbers: Array(251 ... 385), title: "Gen. III"),
	                                         PokédexRange(dexNumbers: Array(386 ... 492), title: "Gen. IV"),
	                                         PokédexRange(dexNumbers: Array(493 ... 648), title: "Gen. V"),
	                                         PokédexRange(dexNumbers: Array(649 ... 720), title: "Gen. VI"),
	                                         PokédexRange(dexNumbers: Array(721 ... 801), title: "Gen. VII")
	]
	
	var selectedIndex = 0
	
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
		let items: [WKPickerItem] = ["I", "II", "III", "IV", "V", "VI", "VII"].map {
			let item = WKPickerItem()
			item.title = $0
			item.caption = "Gen. \($0)"
			return item
		}
		
		generationPicker.setItems(items)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
	
	@IBAction func browseButtonPressed() {
		presentController(withName: "PokedexList", context: generationRanges[selectedIndex])
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
				self.present(pokémon: pokémon)
			} else {
				self.presentController(withName: "PokedexList", context: range)
			}
			
			
		}
	}
	
	@IBAction func recentsButtonPressed() {
		presentController(withName: "PokedexList", context: recentsRange)
	}
	
	@IBAction func generationPickerSelected(_ value: Int) {
		selectedIndex = value
	}
	
	
	func search(query: String) -> PokédexRange {
		let query = query.lowercased().capitalized
		let nums = allPokémonInfo.flatMap { $0 }.filter {
			$0.id <= 802 && $0.name.hasPrefix(query)
			}.sorted { first, second in
				first.name < second.name
			}.map {
				$0.id
		}
		
		return PokédexRange(dexNumbers: nums, title: "\(nums.count) \("Result".pluralize(count: nums.count))")
	}
	
}
