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
	@IBOutlet var pokemonWithThisMoveButton: WKInterfaceButton!
	
	var move: Move!
	var otherPokémonRange: PokédexRange?
	
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
		if let range = otherPokémonRange {
			pushController(withName: "PokedexList", context: range)
			return
		}
		
		Pokédex.findAllPokémon(whoKnow: move, completion: { [weak self] range in
			guard let strongSelf = self else { return }
			
			self?.otherPokémonRange = range
			strongSelf.pushController(withName: "PokedexList", context: range)
			strongSelf.pokemonWithThisMoveButton.setEnabled(true)
			strongSelf.pokemonWithThisMoveButton.setTitle("\(range.ids.count) Pokémon With This Move")
		}) { [weak self] completed, total in
			let str = String(format: "%.0f%%", (Double(completed)/Double(total))*100)
			self?.pokemonWithThisMoveButton.setTitle("Searching…\n\(str)")
		}
		
		pokemonWithThisMoveButton.setEnabled(false)
		
	}
}
