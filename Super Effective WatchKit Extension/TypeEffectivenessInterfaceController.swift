//
//  TypeEffectivenessInterfaceController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 12/24/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import Foundation
import WatchKit
import PokeKit

class TypeEffectivenessInterfaceController: WKInterfaceController {

	@IBOutlet var superEffectiveTable: WKInterfaceTable!
	@IBOutlet var notVeryEffectiveTable: WKInterfaceTable!
	@IBOutlet var noEffectTable: WKInterfaceTable!
	@IBOutlet var superEffectiveNoneLabel: WKInterfaceLabel!
	@IBOutlet var notVeryEffectiveNoneLabel: WKInterfaceLabel!
	@IBOutlet var noEffectNoneLabel: WKInterfaceLabel!
	@IBOutlet var normalEffectiveTable: WKInterfaceTable!
	@IBOutlet var normalEffectiveNoneLabel: WKInterfaceLabel!
	
	var matchup: TypeMatchup!
	
	override func awake(withContext context: Any?) {
		guard let combination = context as? TypeCombination else {
			print("Couldn't read combination")
			return
		}
		guard let matchup = allTypeMatchups.first(where: { $0.defendingType == combination }) else {
			print("Invalid matchup (somehow)")
			return
		}
		
		self.matchup = matchup
		
		setTitle(String(describing: combination))
		
		populateTables()
	}
	
	func populateTables() {
		var superEffectiveTypes = [(type: Type, value: Double)]()
		var notVeryEffectiveTypes = [(type: Type, value: Double)]()
		var noEffectTypes = [(type: Type, value: Double)]()
		var normalEffectiveTypes = [(type: Type, value: Double)]()
		
		for (type, value) in matchup.effectiveness {
			switch value {
			case 0:
				noEffectTypes.append((type: type, value: value))
			case 2, 4:
				superEffectiveTypes.append((type: type, value: value))
			case 0.5, 0.125:
				notVeryEffectiveTypes.append((type: type, value: value))
			case 1:
				normalEffectiveTypes.append((type: type, value: value))
			default:
				break
			}
		}
		
		// Sort by name
		superEffectiveTypes.sort { first, second in
			return first.type.rawValue < second.type.rawValue
		}
		notVeryEffectiveTypes.sort { first, second in
			return first.type.rawValue < second.type.rawValue
		}
		noEffectTypes.sort { first, second in
			return first.type.rawValue < second.type.rawValue
		}
		normalEffectiveTypes.sort { first, second in
			return first.type.rawValue < second.type.rawValue
		}
		
		// Sort by value
		superEffectiveTypes.sort { first, second in
			return first.value > second.value
		}
		notVeryEffectiveTypes.sort { first, second in
			return first.value < second.value
		}
		noEffectTypes.sort { first, second in
			return first.value < second.value
		}
		normalEffectiveTypes.sort { first, second in
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
		
		if superEffectiveTypes.isEmpty {
			superEffectiveNoneLabel.setHidden(false)
		} else {
			superEffectiveNoneLabel.setHidden(true)
		}
		
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
		
		if notVeryEffectiveTypes.isEmpty {
			notVeryEffectiveNoneLabel.setHidden(false)
		} else {
			notVeryEffectiveNoneLabel.setHidden(true)
		}
		
		// No Effect
		
		noEffectTable.setNumberOfRows(noEffectTypes.count, withRowType: "TypeRow")
		for (index, type) in noEffectTypes.enumerated() {
			let row = noEffectTable.rowController(at: index) as! TypeRowController
			row.type = type.type
			row.effectivenessLabel.setText("0x")
		}
		
		if noEffectTypes.isEmpty {
			noEffectNoneLabel.setHidden(false)
		} else {
			noEffectNoneLabel.setHidden(true)
		}
		
		// Normal Effect
		
		normalEffectiveTable.setNumberOfRows(normalEffectiveTypes.count, withRowType: "TypeRow")
		for (index, type) in normalEffectiveTypes.enumerated() {
			let row = normalEffectiveTable.rowController(at: index) as! TypeRowController
			row.type = type.type
			row.effectivenessLabel.setText("1x")
		}
		
		if normalEffectiveTypes.isEmpty {
			normalEffectiveNoneLabel.setHidden(false)
		} else {
			normalEffectiveNoneLabel.setHidden(true)
		}
	}
	
}
