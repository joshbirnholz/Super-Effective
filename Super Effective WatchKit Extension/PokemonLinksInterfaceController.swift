//
//  PokemonLinksInterfaceController.swift
//  Super Effective WatchKit Extension
//
//  Created by Josh Birnholz on 9/5/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation
import PokeKit

class PokemonLinksInterfaceController: PokémonRepresentingInterfaceController {
	
	@IBOutlet var icon: WKInterfaceImage!
	
	override func awake(withContext context: Any?) {
        super.awake(withContext: context)
		
		guard let pokémon = context as? Pokémon else {
			print("Didn't get Pokémon")
			return
		}
		
		self.pokémon = pokémon
		
		setTitle(pokémon.name)
		icon.setImage(pokémon.icon)
		
		setFavoriteMenuItem()
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
	
	override func didAppear() {
		updateRecents(withID: pokémon.id)
	}
	
	override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
		return pokémon
	}

}
