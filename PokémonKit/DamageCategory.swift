//
//  DamageCategory.swift
//  Super Effective
//
//  Created by Josh Birnholz on 12/22/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import UIKit

public enum DamageCategory: String, Codable {
	case physical = "Physical"
	case special = "Special"
	case status = "Status"
	
	public var color: UIColor {
		switch self {
		case .physical: return #colorLiteral(red: 0.7865435481, green: 0.1308320761, blue: 0.06938286126, alpha: 1)
		case .special: return #colorLiteral(red: 0.2175755238, green: 0.4998678765, blue: 0.9402694106, alpha: 1)
		case .status: return #colorLiteral(red: 0.5486858487, green: 0.5330883861, blue: 0.5505231023, alpha: 1)
		}
	}
	
	public var symbol: UIImage {
		switch self {
		case .physical: return #imageLiteral(resourceName: "physical")
		case .special: return #imageLiteral(resourceName: "Special")
		case .status: return #imageLiteral(resourceName: "Status")
		}
	}
}
