//
//  DamageTakenTableViewController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 9/25/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import UIKit
import PokeKit_iOS

class DamageTakenCell: UITableViewCell {
	@IBOutlet weak var typeView: UIView!
	@IBOutlet weak var typeLabel: UILabel!
	@IBOutlet weak var damageLabel: UILabel!
}

class DamageTakenTableViewController: UITableViewController, PokémonRepresentingController {

	var superEffectiveTypes = [(type: Type, value: Double)]()
	var notVeryEffectiveTypes = [(type: Type, value: Double)]()
	var noEffectTypes = [(type: Type, value: Double)]()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		if let _ = pokémon {
			didUpdatePokémon()
		}
    }
	
	func didUpdatePokémon() {
		
		let matchup = TypeMatchup(defendingType: pokémon.type)
		
		superEffectiveTypes.removeAll()
		notVeryEffectiveTypes.removeAll()
		noEffectTypes.removeAll()
		
		for (type, value) in matchup.effectiveness {
			switch value {
			case 0:
				noEffectTypes.append((type: type, value: value))
			case 2, 4:
				superEffectiveTypes.append((type: type, value: value))
			case 0.5, 0.25:
				notVeryEffectiveTypes.append((type: type, value: value))
			default:
				break
			}
		}
		
		superEffectiveTypes.sort { first, second in
			return first.type.rawValue < second.type.rawValue
		}
		notVeryEffectiveTypes.sort { first, second in
			return first.type.rawValue < second.type.rawValue
		}
		noEffectTypes.sort { first, second in
			return first.type.rawValue < second.type.rawValue
		}
		
		superEffectiveTypes.sort { first, second in
			return first.value > second.value
		}
		notVeryEffectiveTypes.sort { first, second in
			return first.value < second.value
		}
		
		tableView?.reloadData()
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		switch section {
		case 0:
			return superEffectiveTypes.count
		case 1:
			return notVeryEffectiveTypes.count
		case 2:
			return noEffectTypes.count
		default:
			return 0
		}
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "DamageTakenCell", for: indexPath) as? DamageTakenCell else {
			return UITableViewCell()
		}

		let info: (type: Type, value: Double) = {
			switch indexPath.section {
			case 0:
				return superEffectiveTypes[indexPath.row]
			case 1:
				return notVeryEffectiveTypes[indexPath.row]
			case 2:
				return noEffectTypes[indexPath.row]
			default:
				return (.normal, 1.0)
			}
		}()
		
		cell.typeView.backgroundColor = info.type.color
		cell.typeView.layer.cornerRadius = 4
		cell.typeLabel.text = info.type.description.uppercased()
		
		switch info.value {
		case 2:
			cell.damageLabel.text = "2x"
		case 4:
			cell.damageLabel.text = "4x"
		case 0.5:
			cell.damageLabel.text = "½x"
		case 0.25:
			cell.damageLabel.text = "¼x"
		case 0:
			cell.damageLabel.text = "0x"
		default:
			cell.damageLabel.text = "1x"
		}

        return cell
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return "Super Effective"
		case 1: return "Not Very Effective"
		case 2: return "No Effect"
		default: return nil
		}
	}

	override func updateUserActivityState(_ activity: NSUserActivity) {
		activity.addUserInfoEntries(from: ["focus": Focus.damageTaken.rawValue])
		super.updateUserActivityState(activity)
	}
	
	enum Section: Int {
		case superEffective
		case notVeryEffective
		case noEffect
		
		init?(focus: Focus) {
			switch focus {
			case .superEffective:
				self = .superEffective
			case .notVeryEffective:
				self = .notVeryEffective
			case .noEffect:
				self = .noEffect
			default:
				return nil
			}
		}
	}
	
	@discardableResult func focus(on section: Section, speak: Bool) -> Bool {
		var types = [superEffectiveTypes, notVeryEffectiveTypes, noEffectTypes][section.rawValue].map { $0.type.description.capitalized + "-" }
		
		tableView.scrollToRow(at: IndexPath(row: types.isEmpty ? NSNotFound : 0, section: section.rawValue), at: .top, animated: true)
		
		let ending: String = {
			switch section {
			case .superEffective:
				return "are super effective"
			case .notVeryEffective:
				return "are not very effective"
			case .noEffect:
				return "have no effect"
			}
		}()
		
		guard !types.isEmpty else {
			siriSpeak("There are no types that \(ending) against \(pokémon.forme).")
			return true
		}
			
		if types.count > 1 {
			types.insert("and", at: types.count-1)
		}
		
		let str = types.joined(separator: ",").replacingOccurrences(of: "and,", with: "and")
			
		siriSpeak("\(str)type moves \(ending) against \(pokémon.forme).")
		
		return true
		
	}
	
}
