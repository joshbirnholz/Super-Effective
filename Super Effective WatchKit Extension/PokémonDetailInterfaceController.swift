//
//  PokémonDetailInterfaceController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 11/25/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation
import PokeKit

class TypeRowController: NSObject {
	
	@IBOutlet var effectivenessLabel: WKInterfaceLabel!
	@IBOutlet private var typeButton: WKInterfaceButton!
	
	var type: Type = .normal {
		didSet {
			typeButton.setTitle(type.rawValue.uppercased())
			typeButton.setBackgroundColor(type.color)
		}
	}
}

class PokémonDetailInterfaceController: PokémonRepresentingInterfaceController {
	
	@IBOutlet var superEffectiveTable: WKInterfaceTable!
	@IBOutlet var notVeryEffectiveTable: WKInterfaceTable!
	@IBOutlet var noEffectTable: WKInterfaceTable!
	@IBOutlet var superEffectiveNoneLabel: WKInterfaceLabel!
	@IBOutlet var notVeryEffectiveNoneLabel: WKInterfaceLabel!
	@IBOutlet var noEffectNoneLabel: WKInterfaceLabel!
	
	override func awake(with context: Pokémon) {
		super.awake(with: context)
		
		setTitle(pokémon.name)
		load(typeCombination: pokémon.type)
		
	}
	
	override func awake(withIncorrectContext context: Any?) {
		if let context = context as? [Any],
			let title = context[safe: 0] as? String,
			let type = context[safe: 1] as? TypeCombination {
			setTitle(title)
			load(typeCombination: type)
		}
	}
	
	func load(typeCombination: TypeCombination) {
		
		let matchup = TypeMatchup(defendingType: typeCombination)
		
		var superEffectiveTypes = [(type: Type, value: Double)]()
		var notVeryEffectiveTypes = [(type: Type, value: Double)]()
		var noEffectTypes = [(type: Type, value: Double)]()
		
		for (type, value) in matchup.effectiveness {
			switch value {
			case 0:
				noEffectTypes.append((type: type, value: value))
			case 2, 4:
				superEffectiveTypes.append((type: type, value: value))
			case 0.5, 0.25:
				notVeryEffectiveTypes.append((type: type, value: value))
			default:
				break
			}
		}
		
		superEffectiveTypes.sort { first, second in
			return first.type.rawValue < second.type.rawValue
		}
		notVeryEffectiveTypes.sort { first, second in
			return first.type.rawValue < second.type.rawValue
		}
		noEffectTypes.sort { first, second in
			return first.type.rawValue < second.type.rawValue
		}
		
		superEffectiveTypes.sort { first, second in
			return first.value > second.value
		}
		notVeryEffectiveTypes.sort { first, second in
			return first.value < second.value
		}
		
		// Super Effective
		
		superEffectiveTable.setNumberOfRows(superEffectiveTypes.count, withRowType: "TypeRow")
		for (index, type) in superEffectiveTypes.enumerated() {
			let row = superEffectiveTable.rowController(at: index) as! TypeRowController
			row.type = type.type
			if type.value == 2 {
				row.effectivenessLabel.setText("2x")
			} else if type.value == 4 {
				row.effectivenessLabel.setText("4x")
			}
		}
		
		superEffectiveNoneLabel.setHidden(!superEffectiveTypes.isEmpty)
		
		// Not Very Effective
		
		notVeryEffectiveTable.setNumberOfRows(notVeryEffectiveTypes.count, withRowType: "TypeRow")
		for (index, type) in notVeryEffectiveTypes.enumerated() {
			let row = notVeryEffectiveTable.rowController(at: index) as! TypeRowController
			row.type = type.type
			if type.value == 0.5 {
				row.effectivenessLabel.setText("½x")
			} else if type.value == 0.25 {
				row.effectivenessLabel.setText("¼x")
			}
		}
		
		notVeryEffectiveNoneLabel.setHidden(!notVeryEffectiveTypes.isEmpty)
		
		// No Effect
		
		noEffectTable.setNumberOfRows(noEffectTypes.count, withRowType: "TypeRow")
		for (index, type) in noEffectTypes.enumerated() {
			let row = noEffectTable.rowController(at: index) as! TypeRowController
			row.type = type.type
			row.effectivenessLabel.setText("0x")
		}
		
		noEffectNoneLabel.setHidden(!noEffectTypes.isEmpty)
		
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
