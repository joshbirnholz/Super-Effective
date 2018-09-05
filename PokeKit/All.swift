//
//  Global.swift
//  Super Effective
//
//  Created by Josh Birnholz on 12/22/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import Foundation

internal let decoder = PropertyListDecoder()

internal let bundle: Bundle? = {
	#if os(iOS)
		return Bundle(identifier: "com.josh.birnholz.PokeKit-iOS")
	#elseif os(watchOS)
		return Bundle(identifier: "com.josh.birnholz.PokeKit")
	#else
		return nil
	#endif
}()

enum FileLoadError: Error {
	case couldNotLoadResource
}

internal func decode<T: Decodable>(_ type: T.Type, fromPropertyListWithName resourceName: String) throws -> T {
	guard let url = bundle?.url(forResource: resourceName, withExtension: "plist") else {
		throw FileLoadError.couldNotLoadResource
	}
	
	let data = try Data(contentsOf: url)
	
	do {
		return try decoder.decode(type, from: data)
	} catch DecodingError.keyNotFound(let key, let context) {
		print(key)
		throw DecodingError.keyNotFound(key, context)
	} catch DecodingError.typeMismatch(let type, let context) {
		print(context.codingPath.map { $0.stringValue })
		throw DecodingError.typeMismatch(type, context)
	} catch {
		print(error.localizedDescription)
		throw error
	}
	
}

/// An array containing `PokémonInfo`	instances for every Pokémon form.
public let allPokémonInfo: [PokémonInfo] = {
	do {
		return try decode([PokémonInfo].self, fromPropertyListWithName: "pokemonnames")
	} catch {
		return []
	}
}()

/// An array containing `TypeMatchup` instances for every possible type matchup.
public let allTypeMatchups: [TypeMatchup] = {
	do {
		return try decode([TypeMatchup].self, fromPropertyListWithName: "typechart")
	} catch {
		return []
	}
}()

/// A dictionary containing the descriptions of every ability, located by their name.
public let allAbilityDescriptions: [String : String] = {
	do {
		return try decode([String: String].self, fromPropertyListWithName: "abilities")
	} catch {
		return [:]
	}
}()

public let allMoveNames: [String] = {
	guard var urls = bundle?.urls(forResourcesWithExtension: "plist", subdirectory: nil) else {
		return []
	}
	return urls.compactMap { url in
		if url.lastPathComponent.hasPrefix("move-") {
			return url.lastPathComponent.replacingOccurrences(of: "move-", with: "").replacingOccurrences(of: ".plist", with: "")
		} else {
			return nil
		}
	}
}()
