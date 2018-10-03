//
//  PokémonRepresentingController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 9/25/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import UIKit
import PokeKit_iOS

protocol PokémonRepresentingController: class {
	var pokémon: Pokémon! { get }
	
	func didUpdatePokémon()
	func focus(on focus: Focus, speak: Bool) -> Bool
}

extension PokémonRepresentingController {
	var pokémon: Pokémon! {
		get {
			return ((self as? UIViewController)?.tabBarController as? PokemonTabBarController)?.pokémon
		}
		set {
			((self as? UIViewController)?.tabBarController as? PokemonTabBarController)?.pokémon = newValue
		}
	}
}
