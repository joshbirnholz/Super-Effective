//
//  EvolutionAndFormsInterfaceController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 11/26/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation
import PokeKit

class EvolutionRowController: NSObject {
	
	@IBOutlet var souceName: WKInterfaceLabel!
	@IBOutlet var sourceIcon: WKInterfaceImage!
	@IBOutlet var sourceForm: WKInterfaceLabel!
	
	@IBOutlet var evolvedNameLabel: WKInterfaceLabel!
	@IBOutlet var evolvedIcon: WKInterfaceImage!
	@IBOutlet var evolvedForm: WKInterfaceLabel!
	
	@IBOutlet var methodLabel: WKInterfaceLabel!
	
	@IBOutlet var sourceButton: WKInterfaceButton!
	@IBOutlet var evolvedButton: WKInterfaceButton!
	
	var sourceButtonHandler: (() -> Void)?
	var evolvedButtonHandler: (() -> Void)?
	
	@IBAction private func souceButtonPressed() {
		sourceButtonHandler?()
	}
	
	@IBAction private func evolvedButtonPressed() {
		evolvedButtonHandler?()
	}
	
	@IBOutlet var separator: WKInterfaceSeparator!
}

class EvolutionAndFormsInterfaceController: PokémonRepresentingInterfaceController {
	
	@IBOutlet var formsHeaderLabel: WKInterfaceLabel!
	@IBOutlet var evolutionsHeaderLabel: WKInterfaceLabel!
	@IBOutlet var evolutionsTable: WKInterfaceTable!
	@IBOutlet var formsListTable: WKInterfaceTable!
	@IBOutlet var noEvolutionsLabel: WKInterfaceLabel!
	
	var altforms = [PokémonInfo]()
	var evolutions = [Evolution]()
	
	override func awake(with context: Pokémon) {
		super.awake(with: context)
		
		setTitle(pokémon.name)
		
		altforms = pokémon.altFormIDs.compactMap { Pokédex.allPokémonInfo[$0] }
		evolutions = pokémon.evolutionTree
		
		if evolutions.isEmpty {
			evolutionsHeaderLabel.setHidden(true)
			evolutionsTable.setHidden(true)
			noEvolutionsLabel.setHidden(false)
		} else {
			populateEvolutionsTable()
		}
		
		if altforms.count <= 1 {
			formsHeaderLabel.setHidden(true)
			formsListTable.setHidden(true)
		} else {
			loadAltForms()
		}
		
		
	}
	
	func loadAltForms() {
		formsListTable.setNumberOfRows(altforms.count, withRowType: "PokemonFormRow")
		
		for (index, info) in altforms.enumerated() {
			let row = formsListTable.rowController(at: index) as! PokémonListRowController
			
			row.nameLabel.setText(info.name)
			row.numberLabel.setText(info.formName)
			
			row.icon.setImage(info.icon)
		}
	}
	
	func populateEvolutionsTable() {
		
		if evolutions.isEmpty {
			evolutionsHeaderLabel.setHidden(true)
		} else {
			evolutionsHeaderLabel.setHidden(false)
		}
		
		evolutionsTable.setNumberOfRows(evolutions.count, withRowType: "EvolutionRow")
		
		for (index, evolution) in evolutions.enumerated() {
			let row = evolutionsTable.rowController(at: index) as! EvolutionRowController
			
			guard let sourcePokémonInfo = Pokédex.allPokémonInfo[evolution.originalSpeciesID],
				let evolvedPokémonInfo = Pokédex.allPokémonInfo[evolution.evolvedSpeciesID] else {
					continue
			}
			
			if sourcePokémonInfo.formName == "" {
				row.sourceForm.setHidden(true)
			}
			
			if evolvedPokémonInfo.formName == "" {
				row.sourceForm.setHidden(true)
			}
			
			if index > 0 && evolutions[index - 1].evolvedSpeciesID == evolution.originalSpeciesID {
				row.sourceButton.setHidden(true)
			} else {
				if index != 0 {
					row.separator.setHidden(false)
				}
				row.sourceIcon.setImage(sourcePokémonInfo.icon)
				row.souceName.setText(sourcePokémonInfo.name)
				row.sourceForm.setText(sourcePokémonInfo.formName)
			}
			
			row.evolvedIcon.setImage(evolvedPokémonInfo.icon)
			row.evolvedNameLabel.setText(evolvedPokémonInfo.name)
			row.evolvedForm.setText(evolvedPokémonInfo.formName)
			row.methodLabel.setText(evolution.conditions)
			
			row.sourceButtonHandler = {
				self.changePokémon(id: sourcePokémonInfo.id)
			}
			
			row.evolvedButtonHandler = {
				self.changePokémon(id: evolvedPokémonInfo.id)
			}
			
		}
		
	}
	
	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		let info = altforms[rowIndex]
		
		print("Form:", info.form)
		print("Form name:", info.formName)
		print("Name:", info.name)
		print("NDex:", info.ndex)
		print("ID:", info.id)
		print("-------------------------------")
		
		changePokémon(id: info.id)
	}
	
	func changePokémon(id: Int) {
		guard let pokémon = Pokémon.with(id: id), id != self.pokémon.id else { return }
		push(pokémon: pokémon)
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
