//
//  AlphabeticalInterfaceController.swift
//  Super Effective WatchKit Extension
//
//  Created by Josh Birnholz on 9/5/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation
import PokeKit

class AlphabeticalInterfaceController: WKInterfaceController {

	func showLetter(_ letter: String = #function) {
		let letter = String(letter[letter.startIndex])
		let nums = Pokédex.allPokémonInfo.filter {
			$0.id <= Pokédex.lastUniquePokémonID && $0.name.lowercased().hasPrefix(letter.lowercased())
			}.sorted { first, second in
				first.name < second.name
			}.map {
				$0.id
		}
		
		let range = PokédexRange(dexNumbers: nums, title: letter.uppercased())
		
		pushController(withName: "PokedexList", context: range)
	}
	
	@IBAction func a() {
		showLetter()
	}
	
	@IBAction func b() {
		showLetter()
	}
	
	@IBAction func c() {
		showLetter()
	}
	
	@IBAction func d() {
		showLetter()
	}
	
	@IBAction func e() {
		showLetter()
	}
	
	@IBAction func f() {
		showLetter()
	}
	
	@IBAction func g() {
		showLetter()
	}
	
	@IBAction func h() {
		showLetter()
	}
	
	@IBAction func i() {
		showLetter()
	}
	
	@IBAction func j() {
		showLetter()
	}
	
	@IBAction func k() {
		showLetter()
	}
	
	@IBAction func l() {
		showLetter()
	}
	
	@IBAction func m() {
		showLetter()
	}
	
	@IBAction func n() {
		showLetter()
	}
	
	@IBAction func o() {
		showLetter()
	}
	
	@IBAction func p() {
		showLetter()
	}
	
	@IBAction func q() {
		showLetter()
	}
	
	@IBAction func r() {
		showLetter()
	}
	
	@IBAction func s() {
		showLetter()
	}
	
	@IBAction func t() {
		showLetter()
	}
	
	@IBAction func u() {
		showLetter()
	}
	
	@IBAction func v() {
		showLetter()
	}
	
	@IBAction func w() {
		showLetter()
	}
	
	@IBAction func x() {
		showLetter()
	}
	
	@IBAction func y() {
		showLetter()
	}
	
	@IBAction func z() {
		showLetter()
	}
	
}
