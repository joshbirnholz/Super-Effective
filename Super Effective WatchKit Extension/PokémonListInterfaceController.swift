//
//  PokémonListInterfaceController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 11/25/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation
import PokeKit

class PokémonListRowController: NSObject {
	
	@IBOutlet var icon: WKInterfaceImage!
	@IBOutlet var nameLabel: WKInterfaceLabel!
	@IBOutlet var numberLabel: WKInterfaceLabel!
	
}

class PokémonListCompactRowController: NSObject {
	
	weak var presenter: WKInterfaceController?
	
	var pokémon: [PokémonInfo] = [] {
		didSet {
			if let pk1 = pokémon[safe: 0] {
				loadImage(in: icon1, for: pk1)
			} else {
				button1.setHidden(true)
			}
			if let pk2 = pokémon[safe: 1] {
				loadImage(in: icon2, for: pk2)
			} else {
				button2.setHidden(true)
			}
			if let pk3 = pokémon[safe: 2] {
				loadImage(in: icon3, for: pk3)
			} else {
				button3.setHidden(true)
			}
		}
	}
	
	@IBOutlet private var icon1: WKInterfaceImage!
	@IBOutlet private var icon2: WKInterfaceImage!
	@IBOutlet private var icon3: WKInterfaceImage!
	@IBOutlet private var button1: WKInterfaceButton!
	@IBOutlet private var button2: WKInterfaceButton!
	@IBOutlet private var button3: WKInterfaceButton!
	
	@IBAction private func button1Pressed() {
		if let pk = pokémon[safe: 0].flatMap({ Pokémon.with(id: $0.id) }), let presenter = presenter {
			presenter.push(pokémon: pk)
		}
	}
	
	@IBAction private func button2Pressed() {
		if let pk = pokémon[safe: 1].flatMap({ Pokémon.with(id: $0.id) }), let presenter = presenter {
			presenter.push(pokémon: pk)
		}
	}
	
	@IBAction private func button3Pressed() {
		if let pk = pokémon[safe: 2].flatMap({ Pokémon.with(id: $0.id) }), let presenter = presenter {
			presenter.push(pokémon: pk)
		}
	}
}

var favorites: [Int] {
	get {
		return (UserDefaults.standard.object(forKey: "favorites") as? [Int]) ?? []
	}
	set {
		UserDefaults.standard.setValue(newValue, forKey: "favorites")
	}
}

func loadImage(in interfaceImage: WKInterfaceImage, for info: PokémonInfo) {
	DispatchQueue.global(qos: .background).async {
		if let image = info.icon {
			DispatchQueue.main.async {
				interfaceImage.setImage(image)
			}
		}
	}
}

class PokémonListInterfaceController: WKInterfaceController {
	
	@IBOutlet var pokemonListTable: WKInterfaceTable!
	
	var isDebug: Bool = false
	var range: PokédexRange!
	
	var info = [PokémonInfo]() {
		didSet {
			displayTable()
		}
	}
	
	enum ListStyle: String {
		case list, compact
		
		static var `default`: ListStyle {
			get {
				return UserDefaults.standard.string(forKey: #function).flatMap { ListStyle(rawValue: $0) } ?? .list
			}
			set {
				UserDefaults.standard.set(newValue.rawValue, forKey: #function)
			}
		}
		
		var other: ListStyle {
			switch self {
			case .list: return .compact
			case .compact: return .list
			}
		}
	}
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		guard let range = context as? PokédexRange else {
			return
		}
		
		self.range = range
		
		setTitle(range.title)
		
		isDebug = range.title.lowercased().contains("debug")
		
		info = range.dexNumbers.compactMap {
			allPokémonInfo[safe: $0]
		}
	}
	
	func loadTable() {
		pokemonListTable.setNumberOfRows(info.count, withRowType: "PokemonListRow")
		
		for index in 0 ..< info.count {
			let pokémonInfo = info[index]
			let row = pokemonListTable.rowController(at: index) as! PokémonListRowController
			
			row.nameLabel.setText(pokémonInfo.name)
			
			if let detailText = range.detailText[pokémonInfo.id] {
				row.numberLabel.setText(detailText)
			} else if range.detailText.isEmpty {
				row.numberLabel.setText("#\(String(format: "%03d", pokémonInfo.ndex))" + (isDebug ? " (\(pokémonInfo.id))" : ""))
			} else {
				row.numberLabel.setText("\n")
			}
			
			loadImage(in: row.icon, for: pokémonInfo)
			
		}
	}
	
	func loadCompactTable() {
		let chunks = info.chunked(by: 3)
		
		pokemonListTable.setNumberOfRows(chunks.count, withRowType: "PokemonCompactListRow")
		
		for index in 0 ..< pokemonListTable.numberOfRows {
			let chunk = chunks[index]
			let row = pokemonListTable.rowController(at: index) as! PokémonListCompactRowController
			row.presenter = self
			row.pokémon = chunk
			
		}
	}
	
//	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
//		print(#function)
//
//		guard let pokémon = Pokémon.with(id: info[rowIndex].id) else { return }
//		push(pokémon: pokémon)
//	}
	
	override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
		guard let pokémon = Pokémon.with(id: info[rowIndex].id) else { return nil }
		return pokémon
	}
	
	@IBAction func sortByNumberButtonPressed() {
		info.sort { first, second in
			if first.ndex == second.ndex {
				return first.id < second.id
			} else {
				return first.ndex < second.ndex
			}
		}
		
		displayTable()
	}
	
	@IBAction func sortByNameButtonPressed() {
		info.sort { first, second in
			return first.name < second.name
		}
		displayTable()
	}
	
	@IBAction func changeViewButtonPressed() {
		ListStyle.default = ListStyle.default.other
		displayTable()
	}
	
	func displayTable() {
		switch ListStyle.default {
		case .compact:
			loadCompactTable()
		case .list:
			loadTable()
		}
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
