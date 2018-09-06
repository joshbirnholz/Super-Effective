//
//  MoreInfoInterfaceController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 11/25/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation
import NKWatchChart
import PokeKit

class MoreInfoInterfaceController: PokémonRepresentingInterfaceController {
	@IBOutlet var icon: WKInterfaceImage!
	@IBOutlet var speciesLabel: WKInterfaceLabel!
	@IBOutlet var heightLabel: WKInterfaceLabel!
	@IBOutlet var weightLabel: WKInterfaceLabel!
//	@IBOutlet var chartImage: WKInterfaceImage!
	@IBOutlet var genderlessLabel: WKInterfaceLabel!
	@IBOutlet var dexEntryLabel: WKInterfaceLabel!
	@IBOutlet var type1button: WKInterfaceButton!
	@IBOutlet var type2button: WKInterfaceButton!
	@IBOutlet var formLabel: WKInterfaceLabel!
	
	@IBOutlet var genderGroup: WKInterfaceGroup!

	@IBOutlet var percentFemaleImage: WKInterfaceImage!
	@IBOutlet var percentMaleImage: WKInterfaceImage!
	@IBOutlet var percentFemaleLabel: WKInterfaceLabel!
	@IBOutlet var percentMaleLabel: WKInterfaceLabel!
	
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
		guard let pokémon = context as? Pokémon else {
			print("Couldn't read Pokémon")
			return
		}
		self.pokémon = pokémon
		
		icon.setImage(pokémon.icon)
		
		setTitle(pokémon.name)
		
		// Form label
		
		if pokémon.name != pokémon.forme {
			let form = pokémon.formName
			formLabel.setText(form)
			formLabel.setHidden(false)
		} else {
			formLabel.setHidden(true)
		}
		
		// Icon
		
		icon.setImage(pokémon.icon)
		
		// Types
		type1button.setTitle(pokémon.type.type1.rawValue.uppercased())
		type1button.setBackgroundColor(pokémon.type.type1.color)
		
		if let type2 = pokémon.type.type2 {
			type2button.setHidden(false)
			type2button.setTitle(type2.rawValue.uppercased())
			type2button.setBackgroundColor(type2.color)
		} else {
			type2button.setHidden(true)
		}

		speciesLabel.setText(pokémon.species)
		heightLabel.setText(pokémon.height)
		weightLabel.setText(pokémon.weight)
		
		if let percentMale = pokémon.percentMale, let percentFemale = pokémon.percentFemale {
//			loadGenderRatioChart(male: percentMale, female: percentFemale)
			percentMaleImage.setRelativeWidth(CGFloat(percentMale), withAdjustment: 0)
			percentFemaleImage.setRelativeWidth(CGFloat(percentFemale), withAdjustment: 0)
			percentMaleLabel.setText("\(percentMale * 100)%")
			percentFemaleLabel.setText("\(percentFemale * 100)%")
		} else {
//			chartImage.setHidden(true)
			genderlessLabel.setHidden(false)
			genderGroup.setHidden(true)
		}
		
//		eggGroupOne.setText(pokémon.eggGroup1)
//		
//		if pokémon.eggGroup2 != "" {
//			eggGroup2.setText(pokémon.eggGroup2)
//		} else {
//			eggGroup2.setHidden(true)
//		}
		
		let dexEntry = [pokémon.dex1, pokémon.dex2].joined(separator: "\n\n")
		
		if dexEntry != "\n\n" {
			dexEntryLabel.setText(dexEntry)
		} else {
			dexEntryLabel.setHidden(true)
		}
		
    }

}
