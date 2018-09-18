//
//  BrowseByTypeInterfaceController.swift
//  Super Effective WatchKit Extension
//
//  Created by Josh Birnholz on 9/7/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation
import PokeKit

class BrowseByTypeInterfaceController: WKInterfaceController {

	@IBOutlet var table: WKInterfaceTable!
	let types = Type.allCases.sorted(by: { $0.rawValue < $1.rawValue })
	
    override func awake(withContext context: Any?) {		
		table.setNumberOfRows(types.count, withRowType: "TypeRow")
		
		for (index, type) in types.enumerated() {
			let row = table.rowController(at: index) as! SimpleRowController
			
			row.label.setText(type.description)
			row.rootGroup.setBackgroundColor(type.color)
		}
    }

	override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
		
		let type = types[rowIndex]
		
		let nums = Pokédex.allPokémonInfo.values.filter {
			$0.id <= Pokédex.lastUniquePokémonID
			}.compactMap {
				Pokémon.with(id: $0.id)
			}.filter {
				$0.type.type1 == type || $0.type.type2 == type
			}.map {
				$0.id
		}
		
		let range = PokédexRange(dexNumbers: nums, title: type.description)
		
		return range
		
	}

}
