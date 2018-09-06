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

	var allPokémon: [Pokémon] = []
	
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
		allPokémon = allPokémonInfo.compactMap { Pokémon.with(id: $0.id) }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	
	func testLoadPokémon() {
		for info in allPokémonInfo {
			XCTAssertNotNil(Pokémon.with(id: info.id))
		}
		
		XCTAssertEqual(allPokémon.count, allPokémonInfo.count)
	}

    func testMoves() {
		for pokémon in allPokémon {
			XCTAssertNoThrow(try Moveset.with(for: pokémon), "Failed to load moves for \(pokémon.forme)")
		}
    }
	
	func testBaseStatTotalsMatch() {
		for pokémon in allPokémon {
			XCTAssertEqual(pokémon.total, [pokémon.attack, pokémon.defense, pokémon.spattack, pokémon.spdefense, pokémon.hp, pokémon.speed].reduce(0, +))
		}
	}

}
