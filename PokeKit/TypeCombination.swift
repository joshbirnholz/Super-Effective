//
//  TypeCombination.swift
//  Super Effective
//
//  Created by Josh Birnholz on 12/22/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import Foundation

public struct TypeCombination: Equatable, CustomStringConvertible {
	public var type1: Type
	public var type2: Type?
	
	public init(_ type1: Type, _ type2: Type?) {
		self.type1 = type1
		self.type2 = type2
	}
	
	public static func == (lhs: TypeCombination, rhs: TypeCombination) -> Bool {
		return (lhs.type1 == rhs.type1) && (lhs.type2 == rhs.type2)
	}
	
	public var description: String {
		var desc = type1.rawValue.capitalized
		if let type2 = type2 {
			desc += "/\(type2.rawValue.capitalized)"
		}
		return desc
	}
}
