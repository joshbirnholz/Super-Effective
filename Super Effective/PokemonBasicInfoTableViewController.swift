//
//  PokemonBasicInfoTableViewController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 9/24/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import UIKit
import PokeKit_iOS
import SafariServices

class PokemonBasicInfoTableViewController: UITableViewController, PokémonRepresentingController {

	@IBOutlet weak var type1View: UIView!
	@IBOutlet weak var type1Label: UILabel!
	@IBOutlet weak var type2View: UIView!
	@IBOutlet weak var type2Label: UILabel!
	@IBOutlet weak var speciesLabel: UILabel!
	@IBOutlet weak var heightLabel: UILabel!
	@IBOutlet weak var weightLabel: UILabel!
	
	@IBOutlet weak var ability1Label: UILabel!
	@IBOutlet weak var ability2Label: UILabel!
	@IBOutlet weak var ability3Label: UILabel!
	@IBOutlet weak var ability2Cell: UITableViewCell!
	@IBOutlet weak var ability3Cell: UITableViewCell!
	@IBOutlet weak var favoritesLabel: UILabel!
	
	/// The view is not ordered based on this enum. Remember to change it to match the order in the storyboard!
	private enum Sections: Int, CaseIterable {
		case basicInfo
		case abilities
		case hiddenAbility
		case links
		case favoritesButton
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		if let _ = pokémon {
			didUpdatePokémon()
		}
		
		[type1View, type2View].forEach {
			$0?.layer.cornerRadius = 4
		}
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	func didUpdatePokémon() {
		
		tableView.reloadData()
		
		title = pokémon.name
		tabBarController?.title = pokémon.name
		tabBarItem.title = pokémon.name
		
		tabBarItem.selectedImage = pokémon.icon?.withRenderingMode(.alwaysOriginal)
		
		let selectedImage: UIImage? = {
			guard let image = pokémon.icon else { return nil }
			UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
			image.draw(at: .zero, blendMode: .normal, alpha: 0.5)
			let newImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return newImage?.withRenderingMode(.alwaysOriginal)
		}()
		
		tabBarItem.image = selectedImage
		
		type1View.backgroundColor = pokémon.type.type1.color
		type1Label.text = pokémon.type.type1.description.uppercased()
		
		if let type2 = pokémon.type.type2 {
			type2View.backgroundColor = type2.color
			type2Label.text = type2.description.uppercased()
			type2View.isHidden = false
		} else {
			type2View.isHidden = true
		}
		
		speciesLabel.text = pokémon.species
		heightLabel.text = pokémon.height
		weightLabel.text = pokémon.weight
		
		ability1Label.text = pokémon.ability1
		ability2Label.text = pokémon.ability2
		ability3Label.text = pokémon.abilityH
		
		updateFavoritesLabelText()
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case Sections.abilities.rawValue, Sections.hiddenAbility.rawValue:
			let abilityName: String = {
				switch indexPath.row {
				case _ where indexPath.section == 2:
					return pokémon.abilityH
				case 0:
					return pokémon.ability1
				case 1:
					return pokémon.ability2
				default:
					return ""
				}
			}()
			
			let alert = UIAlertController(title: abilityName, message: Pokédex.allAbilityDescriptions[abilityName], preferredStyle: .alert)
			
			let moreInfoAction = UIAlertAction(title: "More Info", style: .default) { action in
				let url = URL(string: "https://bulbapedia.bulbagarden.net/wiki/\(abilityName)_(Ability)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
				
				let safariVC = SFSafariViewController(url: url)
				
				safariVC.modalPresentationStyle = .formSheet
			
				self.present(safariVC, animated: true, completion: nil)
			}
			
			alert.addAction(moreInfoAction)
			
			let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
			alert.addAction(okAction)
			
			present(alert, animated: true, completion: nil)
			tableView.deselectRow(at: indexPath, animated: true)
		case Sections.links.rawValue:
			let safariVC = SFSafariViewController(url: pokémon.bulbapediaURL)
			
			safariVC.modalPresentationStyle = .pageSheet
			
			self.present(safariVC, animated: true, completion: nil)
			tableView.deselectRow(at: indexPath, animated: true)
		case Sections.favoritesButton.rawValue:
			addOrRemoveFromFavorites(pokémon.id)
			
			updateFavoritesLabelText()
			tableView.deselectRow(at: indexPath, animated: true)
		default:
			tableView.deselectRow(at: indexPath, animated: true)
		}
	}
	
	func updateFavoritesLabelText() {
		favoritesLabel.text = favoritesRange.ids.contains(pokémon.id) ? "Remove from Favorites" : "Add to Favorites"
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case Sections.abilities.rawValue where pokémon.ability1 == pokémon.ability2 || pokémon.ability2.isEmpty:
			return "Ability"
		case Sections.hiddenAbility.rawValue where pokémon.abilityH.isEmpty || (pokémon.abilityH == pokémon.ability1 && (pokémon.ability1 == pokémon.ability2 || pokémon.ability2.isEmpty)):
			return nil
		default:
			return super.tableView(tableView, titleForHeaderInSection: section)
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case Sections.abilities.rawValue:
			return !pokémon.ability2.isEmpty && pokémon.ability2 != pokémon.ability1 ? 2 : 1
		case Sections.hiddenAbility.rawValue:
			return pokémon.abilityH.isEmpty || (pokémon.abilityH == pokémon.ability1 && (pokémon.ability1 == pokémon.ability2 || pokémon.ability2.isEmpty)) ? 0 : 1
		default:
			return super.tableView(tableView, numberOfRowsInSection: section)
		}
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return pokémon == nil ? 0 : super.numberOfSections(in: tableView)
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if tableView.numberOfRows(inSection: indexPath.section) == 0 {
			return 0
		}
		
		return super.tableView(tableView, heightForRowAt: indexPath)
	}
	
	override func updateUserActivityState(_ activity: NSUserActivity) {
		activity.addUserInfoEntries(from: ["focus": Focus.basicDetail.rawValue])
		super.updateUserActivityState(activity)
	}

}
