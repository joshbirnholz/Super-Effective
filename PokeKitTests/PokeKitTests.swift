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

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	
	func testLoadPokémon() {
		for info in allPokémonInfo {
			XCTAssertNotNil(Pokémon.with(id: info.id))
		}
	}

    func testMoves() {
		for info in allPokémonInfo {
			guard let pokémon = Pokémon.with(id: info.id) else { continue }
			XCTAssertNotNil(Moveset.with(formName: pokémon.forme), "Failed to load moves for \(pokémon.forme)")
		}
    }

}
