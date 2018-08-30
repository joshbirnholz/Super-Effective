// This file was generated by json2swift.

import Foundation

/// 
public struct Moveset {
	public let forme: String
	public let moves: [(method: String, move: String)]
	public let ndex: Int
	public let species: String
	public init(forme: String, moves: [(method: String, move: String)], ndex: Int, species: String) {
		self.forme = forme
		self.moves = moves
		self.ndex = ndex
		self.species = species
	}
	public init?(json: [String: Any]) {
		guard let forme = json["forme"] as? String else { return nil }
		guard let ndexStr = json["ndex"] as? String else { return nil }
		guard let ndex = Int(ndexStr) else { return nil }
		guard let species = json["species"] as? String else { return nil }
		guard let movesArr = json["moves"] as? [[String : String]] else { return nil }
		
		let moves: [(method: String, move: String)] = movesArr.flatMap {
			guard let method = $0["method"], let name = $0["name"] else { return nil }
			return (method: method, move: name)
		}
		
		self.init(forme: forme, moves: moves, ndex: ndex, species: species)
	}
	
	public static func with(formName: String) -> Moveset? {
		guard let movesetURL = bundle?.url(forResource: "moveset-\(formName)", withExtension: "plist"),
			let dict = [String: Any].contents(of: movesetURL) else {
				return nil
		}
		return Moveset(json: dict)
	}
}