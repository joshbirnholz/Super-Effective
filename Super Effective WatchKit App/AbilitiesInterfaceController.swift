//
//  AbilitiesInterfaceController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 11/25/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation
import PokeKit

class AbilitiesInterfaceController: PokémonRepresentingInterfaceController {
	
	@IBOutlet var ability1Button: WKInterfaceButton!
	
	@IBOutlet var ability2Label: WKInterfaceButton!
	
	@IBOutlet var hiddenAbilityLabel: WKInterfaceLabel!
	@IBOutlet var hiddenAbilityButton: WKInterfaceButton!
	
	var ability1: String?
	var ability2: String?
	var hiddenAbility: String?
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
		guard let pokémon = context as? Pokémon else {
			print("Couldn't read Pokémon")
			return
		}
		
		setTitle(pokémon.name)
		
		self.pokémon = pokémon
		
		setFavoriteMenuItem()
		
		ability1Button.setTitle(pokémon.ability1)
		ability2Label.setTitle(pokémon.ability2)
		hiddenAbilityButton.setTitle(pokémon.abilityH)
		
		if allAbilityDescriptions.keys.contains(pokémon.ability1) {
			ability1 = pokémon.ability1
		}
		
		if allAbilityDescriptions.keys.contains(pokémon.ability2),
			pokémon.ability1 != pokémon.ability2 {
			
			ability2 = pokémon.ability2
		}
		
		if allAbilityDescriptions.keys.contains(pokémon.abilityH),
			pokémon.abilityH != pokémon.ability1 && ((pokémon.ability1 != pokémon.ability2) || (pokémon.ability2 == "")) {
			
			hiddenAbility = pokémon.abilityH
		}
		
		if ability1 == nil {
			ability1Button.setHidden(true)
		}
		
		if ability2 == nil {
			ability2Label.setHidden(true)
		}
		
		if hiddenAbility == nil {
			hiddenAbilityLabel.setHidden(true)
			hiddenAbilityButton.setHidden(true)
		}
	}
	
	@IBAction func ability1ButtonPressed() {
		guard let ability = ability1 else { return }
		let okAction = WKAlertAction(title: "OK", style: .default, handler: { })
		self.presentAlert(withTitle: ability, message: allAbilityDescriptions[ability], preferredStyle: .alert, actions: [okAction])
	}
	
	@IBAction func ability2Pressed() {
		guard let ability = ability2 else { return }
		let okAction = WKAlertAction(title: "OK", style: .default, handler: { })
		self.presentAlert(withTitle: ability, message: allAbilityDescriptions[ability], preferredStyle: .alert, actions: [okAction])
	}
	
	@IBAction func hiddenAbilityPressed() {
		guard let ability = hiddenAbility else { return }
		let okAction = WKAlertAction(title: "OK", style: .default, handler: { })
		self.presentAlert(withTitle: ability, message: allAbilityDescriptions[ability], preferredStyle: .alert, actions: [okAction])
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
