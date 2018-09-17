//
//  MoveDetailInterfaceController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 11/26/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation
import PokeKit

class MoveDetailInterfaceController: TypedInterfaceController<String> {
	
	@IBOutlet var typeButton: WKInterfaceButton!
	@IBOutlet var categoryButton: WKInterfaceGroup!
	@IBOutlet var categoryImage: WKInterfaceImage!
	@IBOutlet var powerLabel: WKInterfaceLabel!
	@IBOutlet var accuracyLabel: WKInterfaceLabel!
	@IBOutlet var descriptionLabel: WKInterfaceLabel!
	@IBOutlet var ppLabel: WKInterfaceLabel!
	@IBOutlet var zmoveEffectLabel: WKInterfaceLabel!
	
	var move: Move!
	
	override func awake(with context: String) {
		do {
			move = try Move.with(name: context)
		} catch {
			print("Error loading move:", error.localizedDescription)
			return
		}
		
		setTitle(move.name)
		typeButton.setTitle(move.type.rawValue.uppercased())
		typeButton.setBackgroundColor(move.type.color)
		
		categoryButton.setBackgroundColor(move.category.color)
		categoryImage.setImage(move.category.symbol)
		
		if let power = move.power, power != 0 {
			powerLabel.setText(String(power))
		} else {
			powerLabel.setText("—")
		}
		
		accuracyLabel.setText(move.accuracy)
		ppLabel.setText(String(move.pp))
		descriptionLabel.setText(move.description)
		zmoveEffectLabel.setText(move.zEffect)
		
		addMenuItem(with: .resume, title: "Home", action: #selector(popToRoot))
	}
	
	@objc func popToRoot() {
		popToRootController()
	}
	
	
	@IBAction func pokemonWithThisMoveButtonPressed() {
		let range = pokémonWhoKnowThisMoveRange()
		pushController(withName: "PokedexList", context: range)
	}
	
	func pokémonWhoKnowThisMoveRange() -> PokédexRange {
		let queue = OperationQueue()
		
		var range = PokédexRange(dexNumbers: [], title: move.name)
		
		let operations: [Operation] = Pokédex.allPokémonInfo.map { info in
			BlockOperation {
				guard let pk = Pokémon.with(id: info.id), let moveset = try? Moveset.moveset(for: pk) else { return }
				if let moveInfo = moveset.moves.first(where: { $0.moveName == self.move.name }) {
					range.dexNumbers.append(info.id)
					range.detailText[info.id] = moveInfo.method
				}
			}
		}
		
		queue.addOperations(operations, waitUntilFinished: true)
		
		range.dexNumbers.sort()
		return range
	}
}
