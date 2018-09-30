//
//  Global.swift
//  Super Effective
//
//  Created by Josh Birnholz on 12/22/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import Foundation

public struct Pokédex {

	internal static let decoder = PropertyListDecoder()

	internal static let bundle: Bundle? = {
		#if os(iOS)
			return Bundle(identifier: "com.josh.birnholz.PokeKit-iOS")
		#elseif os(watchOS)
			return Bundle(identifier: "com.josh.birnholz.PokeKit")
		#else
			return nil
		#endif
	}()

	enum FileLoadError: Error {
		case couldNotLoadResource(name: String)
		
		var localizedDescription: String {
			switch self {
			case .couldNotLoadResource(let name):
				return "The resource named \"\(name)\" does not exist."
			}
		}
	}

	internal static func decode<T: Decodable>(_ type: T.Type, fromPropertyListWithName resourceName: String) throws -> T {
		guard let url = bundle?.url(forResource: resourceName, withExtension: "plist") else {
			throw FileLoadError.couldNotLoadResource(name: resourceName)
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

	/// An array containing `PokémonInfo` instances for every Pokémon form.
	public static let allPokémonInfo: [Int: PokémonInfo] = {
		do {
			let arr = try decode([PokémonInfo].self, fromPropertyListWithName: "pokemonnames")
			let dict = Dictionary(grouping: arr, by: {
				return $0.id
			}).filter({ _, values in
				return values.count == 1
			}).mapValues({ $0.first! })
			return dict
		} catch {
			return [:]
		}
	}()

	/// A dictionary containing the descriptions of every ability, located by their name.
	public static let allAbilityDescriptions: [String : String] = {
		do {
			return try decode([String: String].self, fromPropertyListWithName: "abilities")
		} catch {
			return [:]
		}
	}()

	public static let allMoveNames: [String] = {
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
	
	/// The completion handler will be called with a `PokédexRange` of all the Pokémon who can learn the specified move.
	/// The range's detail text will contain the method that Pokémon learns the move.
	///
	/// - Parameters:
	///   - move: The move in question
	///   - completion: Takes a `PokédexRange` containing the Pokémon who learn the move
	///   - progressCallback: Has two `Int` parameters, the number of Pokémon searched and the total number of Pokémon to search through
	public static func findAllPokémon(whoKnow move: Move, completion: @escaping (PokédexRange) -> (), progressCallback: ((Int, Int) -> ())? = nil) {
		DispatchQueue.global(qos: .userInitiated).async {
			let queue = OperationQueue()
			
			var range = PokédexRange(dexNumbers: [], title: move.name)
			
			let total = Pokédex.allPokémonInfo.count
			let moveQueue = DispatchQueue(label: "movequeue")
			
			let operations: [Operation] = Pokédex.allPokémonInfo.values.sorted { $0.name < $1.name }.map { (info) in
				BlockOperation {
					defer {
						DispatchQueue.main.async {
							progressCallback?(total - queue.operationCount, total)
						}
					}
					guard let pk = Pokémon.with(id: info.id), let moveset = try? Moveset.moveset(for: pk) else { return }
					if let moveInfo = moveset.moves.first(where: { $0.moveName == move.name }) {
						moveQueue.sync {
							range.ids.append(info.id)
							range.detailText[info.id] = moveInfo.method
						}
					}
				}
			}
			
			queue.addOperations(operations, waitUntilFinished: true)
			
			range.ids.sort()
			
			DispatchQueue.main.async {
				completion(range)
			}
		}
		
	}
	
	/// The ID of the final Pokémon in the National Dex. This should be one less than the final Pokémon's number.
	public static let lastUniquePokémonID = 806
	
	public static func search(query: String) -> PokédexRange {
		let query = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
		let queryNum = Int(query)
		let nums = Pokédex.allPokémonInfo.values.filter {
			$0.id <= Pokédex.lastUniquePokémonID && ($0.name.lowercased().contains(query) || String($0.ndex).hasPrefix(query))
			}.sorted { first, second in
				if let queryNum = queryNum {
					if first.ndex == queryNum {
						return true
					} else if second.ndex == queryNum {
						return false
					}
				}
				 
				return first.name < second.name
			}.map {
				$0.id
		}
		
		return PokédexRange(dexNumbers: nums, title: "\(nums.count) \("Result".pluralize(count: nums.count))")
	}

}
