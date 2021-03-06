//
//  PokeKitTests.swift
//  PokeKitTests
//
//  Created by Josh Birnholz on 9/5/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import XCTest
import PokeKit_iOS

class PokeKitTests: XCTestCase {

	let allPokémon: [Pokémon] = Pokédex.allPokémonInfo.values.compactMap { Pokémon.with(id: $0.id) }.sorted { $0.id < $1.id }
	
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	
	func testLoadPokémon() {
		for (id, _) in Pokédex.allPokémonInfo {
			XCTAssertNotNil(Pokémon.with(id: id))
		}
		
		XCTAssertEqual(allPokémon.count, Pokédex.allPokémonInfo.count)
	}

    func testMovesets() {
		for pokémon in allPokémon {
			XCTAssertNoThrow(try Moveset.moveset(for: pokémon), "(\(pokémon.forme))")
		}
    }
	
	func testMoves() {
		var movesTested: [String] = []
		for moveset in allPokémon.compactMap({ try? Moveset.moveset(for: $0) }) {
			for moveInfo in moveset.moves {
				if !movesTested.contains(moveInfo.moveName) {
					XCTAssertNoThrow(try Move.with(name: moveInfo.moveName), "(\(moveset.forme))")
					movesTested.append(moveInfo.moveName)
				}
			}
		}
	}
	
	func testBaseStatTotalsMatch() {
		for pokémon in allPokémon {
			let total = [pokémon.attack, pokémon.defense, pokémon.spattack, pokémon.spdefense, pokémon.hp, pokémon.speed].reduce(0, +)
			XCTAssertEqual(pokémon.total, total, "Incorrect total for \(pokémon.forme) (\(pokémon.id)); Should be \(total)")
		}
	}

	func testLastNationalDexNumberCorrect() {
		XCTAssertEqual(allPokémon.first(where: { $0.ndex != $0.id+1 })!.id-1, Pokédex.lastUniquePokémonID)
	}
	
	// This generates the JSON to be used in the Siri Shortcut to check Pokémon names.
	func testPokemonNames() {
		var dict = [String: String]()
		for pk in Pokédex.allPokémonInfo.values.sorted(by: {$0.id < $1.id}) {
			dict[String(pk.id)] = pk.name.lowercased()
		}
		
		let json = try! JSONSerialization.data(withJSONObject: dict, options: [])
		let str = String(data: json, encoding: .utf8)!
		print(str)
	}
	
}
