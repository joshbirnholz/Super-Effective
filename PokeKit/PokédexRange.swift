//
//  PokédexRange.swift
//  Super Effective
//
//  Created by Josh Birnholz on 12/22/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import Foundation

public struct PokédexRange {
	public var dexNumbers: [Int]
	public var title: String
	
	public init(dexNumbers: [Int], title: String) {
		self.dexNumbers = dexNumbers
		self.title = title
	}
	
}
