import Foundation

public struct Moveset: Codable {
	public struct MoveInfo: Codable {
		public var method: String
		public var moveName: String
		
		public enum CodingKeys: String, CodingKey {
			case method
			case moveName = "name"
		}
	}
	
	public let forme: String
	public let moves: [MoveInfo]
	public let ndex: Int
	public let species: String
	
	public init(forme: String, moves: [MoveInfo], ndex: Int, species: String) {
		self.forme = forme
		self.moves = moves
		self.ndex = ndex
		self.species = species
	}
	
	public init (from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		forme = try values.decode(String.self, forKey: .forme)
		moves = try values.decode([MoveInfo].self, forKey: .moves)
		species = try values.decode(String.self, forKey: .species)
		guard let ndex = Int(try values.decode(String.self, forKey: .ndex)) else {
			throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [Moveset.CodingKeys.ndex], debugDescription: "An Int could not be created from the string value of ndex."))
			
		}
		self.ndex = ndex
	}
	
	public static func with(for pokémon: Pokémon) throws -> Moveset {
		do {
			return try decode(Moveset.self, fromPropertyListWithName: "moveset-\(pokémon.forme)")
		} catch FileLoadError.couldNotLoadResource {
			return try decode(Moveset.self, fromPropertyListWithName: "moveset-\(pokémon.name)")
		}
		
	}
}
