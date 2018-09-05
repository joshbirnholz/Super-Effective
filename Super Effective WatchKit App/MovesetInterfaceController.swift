//
//  MovesetInterfaceController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 11/26/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation
import PokeKit

class MovesetRowController: NSObject {
	
	@IBOutlet var methodLabel: WKInterfaceLabel!
	@IBOutlet var moveNameLabel: WKInterfaceLabel!
}

class MovesetInterfaceController: WKInterfaceController {
	@IBOutlet var movesetTable: WKInterfaceTable!
	
	var moveset: Moveset!
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
		guard let formeName = (context as? Pokémon)?.forme else {
			print("Couldn't read form name")
			return
		}
		
		setTitle((context as? Pokémon)?.name)
		
		guard let moveset = Moveset.with(formName: formeName) else {
			print("Couldn't read moveset")
			return
		}
		self.moveset = moveset
		
		movesetTable.setNumberOfRows(moveset.moves.count, withRowType: "MovesetRow")
		
		for (index, move) in moveset.moves.enumerated() {
			let row = movesetTable.rowController(at: index) as! MovesetRowController
			
			let method: String = {
				if move.method.uppercased().hasPrefix("L") {
					return move.method.uppercased().replacingOccurrences(of: "L", with: "LEVEL ")
				} else {
					return move.method.uppercased()
				}
			}()
			
			row.methodLabel.setText(method)
			row.moveNameLabel.setText(move.moveName)
		}
	}
	
	override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
		return moveset.moves[rowIndex].moveName
	}
	
}
