// This file was generated by json2swift.

import Foundation
import UIKit

/// Represents some information about a Pokémon, but not all. 
public struct PokémonInfo: Codable, Equatable {
	/// The name of the Pokémon's form
	public let form: String
	
	/// The ID for this form of the Pokémon
	public let id: Int
	
	/// The name of the kind of Pokémon
	public let name: String
	
	/// The national dex number of the Pokémon
	public let ndex: Int
	
	public var formName: String {
		return form.replacingOccurrences(of: name, with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "Forme", with: "").replacingOccurrences(of: "Form", with: "") .trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "  ", with: " ")
	}
	
	public var icon: UIImage? {
		if id <= 801 {
			return UIImage(named: "\(ndex).png")
		}
		
		let formName = "\(self.formName.lowercased().replacingOccurrences(of: "forme", with: "").replacingOccurrences(of: "form", with: "").trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "-").replacingOccurrences(of: ":", with: "-").replacingOccurrences(of: "--", with: "-"))".replacingOccurrences(of: "é", with: "e")
		let ndexString = String(ndex)
		let iconName = (formName.isEmpty ? ndexString : "\(ndexString)-\(formName)") + ".png"
		return UIImage(named: iconName)
	}
	
	public static func == (lhs: PokémonInfo, rhs: PokémonInfo) -> Bool {
		return lhs.id == rhs.id
	}
}
