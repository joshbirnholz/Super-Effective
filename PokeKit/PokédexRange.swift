//
//  PokédexRange.swift
//  Super Effective
//
//  Created by Josh Birnholz on 12/22/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import Foundation

public struct PokédexRange {
	public var ids: [Int]
	public var title: String
	public var detailText: [Int: String] = [:]
	
	public init(dexNumbers: [Int], title: String) {
		self.ids = dexNumbers
		self.title = title
	}
	
}
