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

	let allPokémon: [Pokémon] = Pokédex.allPokémonInfo.compactMap { Pokémon.with(id: $0.id) }
	
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	
	func testLoadPokémon() {
		for info in Pokédex.allPokémonInfo {
			XCTAssertNotNil(Pokémon.with(id: info.id))
		}
		
		XCTAssertEqual(allPokémon.count, Pokédex.allPokémonInfo.count)
	}

    func testMovesets() {
		for pokémon in allPokémon {
			XCTAssertNoThrow(try Moveset.with(for: pokémon), "Failed to load moveset for \(pokémon.forme)")
		}
    }
	
	func testMoves() {
		var movesTested: [String] = []
		for moveset in allPokémon.compactMap({ try? Moveset.with(for: $0) }) {
			for moveInfo in moveset.moves {
				if !movesTested.contains(moveInfo.moveName) {
					XCTAssertNoThrow(try Move.with(name: moveInfo.moveName), "Failed to load move for \"\(moveInfo.moveName)\"")
					movesTested.append(moveInfo.moveName)
				}
			}
		}
	}
	
	func testBaseStatTotalsMatch() {
		for pokémon in allPokémon {
			XCTAssertEqual(pokémon.total, [pokémon.attack, pokémon.defense, pokémon.spattack, pokémon.spdefense, pokémon.hp, pokémon.speed].reduce(0, +))
		}
	}

	func testLastNationalDexNumberCorrect() {
		XCTAssertEqual(allPokémon.first(where: { $0.ndex != $0.id+1 })!.id-1, Pokédex.lastUniquePokémonID)
	}
	
}
