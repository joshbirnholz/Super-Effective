//
//  Global.swift
//  Super Effective
//
//  Created by Josh Birnholz on 12/22/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import Foundation

internal let bundle: Bundle? = {
	#if os(iOS)
		return Bundle(identifier: "com.josh.birnholz.PokeKit-iOS")
	#elseif os(watchOS)
		return Bundle(identifier: "com.josh.birnholz.PokeKit")
	#else
		return nil
	#endif
}()

/// An array containing `PokémonInfo`	instances for every Pokémon form.
public let allPokémonInfo: [PokémonInfo] = {
	guard let namesURL = bundle?.url(forResource: "pokemonnames", withExtension: "plist"),
		let namesArray = [[String: Any]].contents(of: namesURL) else {
			return []
	}
	
	var arr = [PokémonInfo?]()
	
	for info in namesArray {
		let pk = PokémonInfo(json: info)
		arr.append(pk)
	}
	arr.insert(nil, at: 0)
	arr.insert(nil, at: 803)
	
	return arr.flatMap { $0 }
}()

/// An array containing `TypeMatchup` instances for every possible type matchup.
public let allTypeMatchups: [TypeMatchup] = {
	guard let typesURL = bundle?.url(forResource: "typechart", withExtension: "plist"),
		let typesArray = [[String: Any]].contents(of: typesURL) else {
			return []
	}
	return typesArray.flatMap { TypeMatchup(json: $0) }
}()

/// A dictionary containing the descriptions of every ability, located by their name.
public let allAbilityDescriptions: [String : String] = {
	guard let abilitiesURL = bundle?.url(forResource: "abilities", withExtension: "plist") else {
		return [:]
	}
	return [String: String].contents(of: abilitiesURL) ?? [:]
}()

public let  allMoveNames: [String] = {
	guard var urls = bundle?.urls(forResourcesWithExtension: "plist", subdirectory: nil) else {
		return []
	}
	return urls.flatMap { url in
		if url.lastPathComponent.hasPrefix("move-") {
			return url.lastPathComponent.replacingOccurrences(of: "move-", with: "").replacingOccurrences(of: ".plist", with: "")
		} else {
			return nil
		}
	}
}()
