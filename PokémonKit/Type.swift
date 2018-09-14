//
//  Type.swift
//  Super Effective
//
//  Created by Josh Birnholz on 12/22/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import UIKit

/// A Pokémon's type.
public enum Type: String, Codable, CodingKey, CaseIterable, CustomStringConvertible {
	
	case normal, fire, fighting, water, flying, grass, poison, electric, ground, psychic, rock, ice, bug, dragon, ghost, dark, steel, fairy
	
	public var color: UIColor {
		switch self {
		case .normal: return #colorLiteral(red: 0.6589151025, green: 0.6577476859, blue: 0.4710216522, alpha: 1)
		case .fire: return #colorLiteral(red: 0.9400577545, green: 0.5037434697, blue: 0.1903759539, alpha: 1)
		case .fighting: return #colorLiteral(red: 0.7516477704, green: 0.1897610426, blue: 0.1562542617, alpha: 1)
		case .water: return #colorLiteral(red: 0.4061568081, green: 0.5664061904, blue: 0.9393417239, alpha: 1)
		case .flying: return #colorLiteral(red: 0.6606838107, green: 0.5629187822, blue: 0.9422370791, alpha: 1)
		case .grass: return #colorLiteral(red: 0.4708993435, green: 0.7852544188, blue: 0.3159823418, alpha: 1)
		case .poison: return #colorLiteral(red: 0.6270785928, green: 0.2517165542, blue: 0.6261646748, alpha: 1)
		case .electric: return #colorLiteral(red: 0.9743724465, green: 0.8147271276, blue: 0.1867141426, alpha: 1)
		case .ground: return #colorLiteral(red: 0.8767636418, green: 0.7539842129, blue: 0.4093942642, alpha: 1)
		case .psychic: return #colorLiteral(red: 0.9739707112, green: 0.3446778059, blue: 0.5311706662, alpha: 1)
		case .rock: return #colorLiteral(red: 0.7203710079, green: 0.6284801364, blue: 0.2188155055, alpha: 1)
		case .ice: return #colorLiteral(red: 0.5973160267, green: 0.846558094, blue: 0.8450990915, alpha: 1)
		case .bug: return #colorLiteral(red: 0.6602682471, green: 0.723259151, blue: 0.1288081408, alpha: 1)
		case .dragon: return #colorLiteral(red: 0.4392063022, green: 0.2215030789, blue: 0.9711959958, alpha: 1)
		case .ghost: return #colorLiteral(red: 0.4375433922, green: 0.346722573, blue: 0.594907105, alpha: 1)
		case .dark: return #colorLiteral(red: 0.4379181266, green: 0.3464794755, blue: 0.2813708186, alpha: 1)
		case .steel: return #colorLiteral(red: 0.721332252, green: 0.7196965814, blue: 0.8168616295, alpha: 1)
		case .fairy: return #colorLiteral(red: 0.9329063296, green: 0.5999090075, blue: 0.6731309891, alpha: 1)
		}
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let rawValue = try container.decode(String.self).lowercased()
		
		guard let value = Type(rawValue: rawValue) else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "The value was not a Type raw value")
		}
		self = value
	}
	
	public var description: String {
		return rawValue.capitalized
	}
}
