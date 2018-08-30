//
//  Extensions.swift
//  Super Effective
//
//  Created by Josh Birnholz on 12/22/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import Foundation

internal extension Array {
	static func contents(of url: URL) -> [Element]? {
		return NSArray(contentsOf: url) as? [Element]
	}
}

internal extension Dictionary {
	static func contents(of url: URL) -> [Key: Value]? {
		return NSDictionary(contentsOf: url) as? [Key: Value]
	}
}
