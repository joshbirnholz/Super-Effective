//
//  UserDefaults.swift
//  Super Effective
//
//  Created by Josh Birnholz on 9/17/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import Foundation

public extension UserDefaults {
	
	public class var group: UserDefaults {
		return UserDefaults(suiteName: "group.com.josh.birnholz.Super-Effective")!
	}
	
}
