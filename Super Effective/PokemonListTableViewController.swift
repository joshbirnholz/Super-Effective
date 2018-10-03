//
//  PokemonListTableViewController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 11/24/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import UIKit
import PokeKit_iOS
import MBProgressHUD

class PokemonListCell: UITableViewCell {
	
	@IBOutlet weak var iconImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var numberLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
	
}

var recents: [Int] {
	get {
		return UserDefaults.group.object(forKey: "recents") as? [Int] ?? []
	}
	set {
		UserDefaults.group.set(newValue, forKey: "recents")
	}
}

var recentsNeedsRedisplay = false
func updateRecents(withID id: Int) {
	recents.insert(id, at: 0)
	recents = Array((NSOrderedSet(array: recents).array as! [Int]).prefix(20))
	recentsNeedsRedisplay = true
}

var recentsRange: PokédexRange {
	return PokédexRange(dexNumbers: recents, title: "Recents")
}

class PokemonListTableViewController: UITableViewController {
	
	private enum Sections: Int, CaseIterable {
		case recentsAndFavorites
		case list
	}
	
	private let searchController = UISearchController(searchResultsController: nil)
	var showsRecentsAndFavorites: Bool = true
	
	var pokedexRange: PokédexRange! {
		didSet {
			navigationItem.title = pokedexRange.title
			pokemon = pokedexRange.ids.compactMap { id in
				Pokédex.allPokémonInfo[id]
			}
		}
	}
	
	private var pokemon: [PokémonInfo] = []
	private var filteredPokemon: [PokémonInfo] = []
	
	/// Show only Pokémon with these types.
	var allowedTypes: Set<Type> = Set(Type.allCases) {
		didSet {
			filterContent(forSearchText: isSearching ? searchController.searchBar.text! : nil, allowedTypes: allowedTypes)
			tableView.reloadData()
		}
	}
	
	private var isSearching: Bool {
		return searchController.isActive && searchController.searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines) != ""
	}
	
	private var activePokemonArray: [PokémonInfo] {
		return isSearching || allowedTypes.count != Type.allCases.count ? filteredPokemon : pokemon
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if pokedexRange == nil {
			pokedexRange = PokédexRange(dexNumbers: Array(0...Pokédex.lastUniquePokémonID), title: "Pokédex")
			filterContent(forSearchText: isSearching ? searchController.searchBar.text! : nil, allowedTypes: allowedTypes)
		}
		
		searchController.searchResultsUpdater = self
		if #available(iOS 11.0, *) {
			navigationItem.searchController = searchController
		} else {
			tableView.tableHeaderView = searchController.searchBar
		}
		searchController.dimsBackgroundDuringPresentation = false
		definesPresentationContext = true
		tableView.keyboardDismissMode = .onDrag
		
		addKeyCommand(UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: [], action: #selector(selectPreviousRow)))
		addKeyCommand(UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: [], action: #selector(selectNextRow)))
	}
	
	@objc func selectPreviousRow() {
		if let indexPath = tableView.indexPathForSelectedRow, indexPath.section == Sections.list.rawValue && indexPath.row > 0 {
			var newIndexPath = indexPath
			newIndexPath.row -= 1
			tableView.deselectRow(at: indexPath, animated: false)
			tableView.selectRow(at: newIndexPath, animated: false, scrollPosition: (tableView.indexPathsForVisibleRows ?? []).contains(newIndexPath) ? .none : .top)
			performSegue(withIdentifier: "ShowPokemon", sender: tableView.cellForRow(at: newIndexPath))
		}
	}
	
	@objc func selectNextRow() {
		if let indexPath = tableView.indexPathForSelectedRow ?? Optional(IndexPath(row: 0, section: Sections.list.rawValue)), indexPath.section == Sections.list.rawValue && indexPath.row < tableView.numberOfRows(inSection: Sections.list.rawValue) - 1 {
			var newIndexPath = indexPath
			newIndexPath.row += 1
			tableView.deselectRow(at: indexPath, animated: false)
			tableView.selectRow(at: newIndexPath, animated: false, scrollPosition: (tableView.indexPathsForVisibleRows ?? []).contains(newIndexPath) ? .none : .bottom)
			performSegue(withIdentifier: "ShowPokemon", sender: tableView.cellForRow(at: newIndexPath))
		}
	}
	
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		if action == #selector(selectPreviousRow) || action == #selector(selectNextRow) {
			return true
		}
		
		return super.canPerformAction(action, withSender: sender)
	}
	
	override var canBecomeFirstResponder: Bool {
		return true
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
//		if #available(iOS 11.0, *) {
//			navigationItem.hidesSearchBarWhenScrolling = false
//		}
		
		if pokedexRange.title == recentsRange.title {
			pokedexRange = recentsRange
			filterContent(forSearchText: isSearching ? searchController.searchBar.text! : nil, allowedTypes: allowedTypes)
			recentsNeedsRedisplay = false
			tableView.reloadData()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
//		if #available(iOS 11.0, *) {
//			navigationItem.hidesSearchBarWhenScrolling = true
//		}
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Sections.allCases.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case Sections.recentsAndFavorites.rawValue:
			return showsRecentsAndFavorites && !isSearching ? 2 : 0
		case Sections.list.rawValue:
			return activePokemonArray.count
		default:
			return 0
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
		case Sections.recentsAndFavorites.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: "GenericCell", for: indexPath)
			
			cell.accessoryType = .disclosureIndicator
			
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = "Favorites"
			case 1:
				cell.textLabel?.text = "Recents"
			default:
				break
			}
			
			return cell
		case Sections.list.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: "PokeCell", for: indexPath) as! PokemonListCell
			
			let info = activePokemonArray[indexPath.row]
			
			cell.iconImageView.image = info.icon
			cell.nameLabel.text = info.name
			cell.numberLabel.text = String(format: "#%03d", info.ndex)
			cell.numberLabel.font = UIFont.monospacedDigitSystemFont(ofSize: cell.numberLabel.font.pointSize, weight: UIFont.Weight.regular)
			
			if let detailText = pokedexRange.detailText[info.id] {
				cell.detailTextLabel?.text = detailText
				cell.detailTextLabel?.isHidden = false
			} else {
				cell.detailTextLabel?.isHidden = true
			}
			
			return cell
		default:
			return UITableViewCell()
		}
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = (segue.destination as? UINavigationController)?.topViewController as? FilterTableViewController, segue.identifier == "ShowFilter" {
			destination.allowedTypes = self.allowedTypes
			
			return
		}
		
		if let userActivity = sender as? NSUserActivity, let destination = (segue.destination as? UINavigationController)?.topViewController as? PokemonTabBarController, userActivity.activityType == "com.josh.birnholz.SuperEffective.ViewPokemon" && segue.identifier == "ShowPokemon" {
			destination.restoreUserActivityState(userActivity)
			return
		}
		
//		if let userActivity = sender as? NSUserActivity,
//			let id = userActivity.userInfo?["id"] as? Int,
//			let pk = Pokémon.with(id: id),
//			let destination = (segue.destination as? UINavigationController)?.topViewController as? PokemonTabBarController, userActivity.activityType == "com.josh.birnholz.SuperEffective.ViewPokemon" && segue.identifier == "ShowPokemon" {
//			destination.pokémon = pk
//			return
//		}
		
		guard let indexPath = (sender as? UITableViewCell).flatMap({ cell in
			return tableView.indexPath(for: cell)
		}) else { return }
		
		switch indexPath.section {
		case Sections.recentsAndFavorites.rawValue:
			guard let vc = segue.destination as? PokemonListTableViewController else {
				return
			}
			
			switch indexPath.row {
			case 0:
				vc.pokedexRange = favoritesRange
			case 1:
				vc.pokedexRange = recentsRange
			default:
				break
			}
			
			vc.showsRecentsAndFavorites = false
		case Sections.list.rawValue:
			
			let info = activePokemonArray[indexPath.row]
			
			guard let pk = Pokémon.with(id: info.id), let vc = (segue.destination as? UINavigationController)?.topViewController as? PokemonTabBarController else {
				return
			}
			
			vc.pokémon = pk
		default:
			break
		}
	}
	
	@available(iOS 11.0, *)
	override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		guard indexPath.section == Sections.list.rawValue else { return nil }
		
		let id = activePokemonArray[indexPath.row].id
		
		let favorite = favoritesRange.ids.contains(id)
		
		let title = favorite ? "Unfavorite" : "Favorite"
		
		let action = UIContextualAction(style: .normal, title: title) { action, view, completionHandler in
			if !addOrRemoveFromFavorites(id) {
				removeFromFavorites(id)
				if self.pokedexRange.title == "Favorites" {
					self.pokedexRange = favoritesRange
					self.filterContent(forSearchText: self.isSearching ? self.searchController.searchBar.text! : nil, allowedTypes: self.allowedTypes)
//					self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
					self.tableView.deleteRows(at: [indexPath], with: .left)
				}
			} else {
				addToFavorites(id)
			}
			completionHandler(true)
		}
		
		action.image = favorite ? UIImage(named: "unlike") : UIImage(named: "like")
		action.backgroundColor = .red
		
		let config = UISwipeActionsConfiguration(actions: [action])
		return config
	}
	
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
			return .none
	}
	
	func filterContent(forSearchText searchText: String? = nil, allowedTypes: Set<Type> = Set(Type.allCases)) {
		var filteredIDs: [Int] = {
			if let searchText = searchText {
				return Pokédex.search(query: searchText).ids
			} else {
				return pokedexRange.ids
			}
		}()
		
		if allowedTypes.count != Type.allCases.count {
			filteredIDs = filteredIDs.filter {
				guard let pk = Pokémon.with(id: $0) else { return false }
				
				if allowedTypes.contains(pk.type.type1) {
					return true
				}
				
				if let type2 = pk.type.type2, allowedTypes.contains(type2) {
					return true
				}
				
				return false
			}
		}
		
		self.filteredPokemon = filteredIDs.compactMap { Pokédex.allPokémonInfo[$0] }

	}
	
	@discardableResult func showMove(named name: String, speak: Bool) -> Bool {
		let hud = MBProgressHUD.showAdded(to: view, animated: true)
		hud.label.text = "Searching…"
		
		func filterName(name: String) -> String {
			return name.lowercased().filter { "abcdefghijklmnopqrstuvwxyz1234567890".contains($0) }
		}
		
		let moveName = filterName(name: name)
		if let originalMoveName = Pokédex.allMoveNames.first(where: { orig in
				filterName(name: orig) == moveName
			}),
			let move = try? Move.with(name: originalMoveName) {
			
			Pokédex.findAllPokémon(whoKnow: move, completion: ({ (range) in
				hud.hide(animated: true)
				
				if speak {
					self.siriSpeak("I found \(range.ids.count) Pokémon that can learn \(move.name).")
				}
				
				guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PokemonListTableViewController") as? PokemonListTableViewController else {
					return
				}
				
				vc.showsRecentsAndFavorites = false
				vc.pokedexRange = range
				
				self.show(vc, sender: self)
			}))
			
			return true
			
		} else if speak {
			self.siriSpeak("I couldn't find a move called \"\(name)\".")
		}
		
		hud.hide(animated: true)
		
		return false
		
	}
	
	@IBAction func unwindToList(segue: UIStoryboardSegue) { }

}

extension PokemonListTableViewController: UISearchResultsUpdating {
	
	func updateSearchResults(for searchController: UISearchController) {
		filterContent(forSearchText: searchController.searchBar.text!, allowedTypes: allowedTypes)
		tableView.reloadData()
	}
	
}

extension PokemonListTableViewController {
	
	override func encodeRestorableState(with coder: NSCoder) {
		super.encodeRestorableState(with: coder)
		if let id = tableView.indexPathForSelectedRow.map({ activePokemonArray[$0.row].id }) {
			coder.encode(id, forKey: "selectedID")
		}
		
		coder.encode(self.allowedTypes.map { $0.rawValue }, forKey: "allowedTypes")
		coder.encode(self.pokedexRange.title, forKey: "pokedexRangeTitle")
		coder.encode(self.pokedexRange.ids, forKey: "pokedexRangeIDs")
		coder.encode(self.pokedexRange.detailText, forKey: "pokedexRangeDetailText")
		coder.encode(self.showsRecentsAndFavorites, forKey: "showsRecentsAndFavorites")
		
	}
	
	override func decodeRestorableState(with coder: NSCoder) {
		super.decodeRestorableState(with: coder)
		
		self.showsRecentsAndFavorites = coder.decodeBool(forKey: "showsRecentsAndFavorites")
		
		if let allowedTypes = coder.decodeObject(forKey: "allowedTypes") as? [Type.RawValue] {
			self.allowedTypes = Set(allowedTypes.compactMap { Type.init(rawValue: $0) })
		}
		
		let id = coder.decodeInteger(forKey: "selectedID")
		
		if let index = activePokemonArray.firstIndex(where: { $0.id == id }), coder.containsValue(forKey: "selectedID") {
			let indexPath = IndexPath(row: index, section: Sections.list.rawValue)
			tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
		}
		
		if let title = coder.decodeObject(forKey: "pokedexRangeTitle") as? String,
			let ids = coder.decodeObject(forKey: "pokedexRangeIDs") as? [Int],
			let detailText = coder.decodeObject(forKey: "pokedexRangeDetailText") as? [Int: String] {
			var range = PokédexRange(dexNumbers: ids, title: title)
			range.detailText = detailText
			self.pokedexRange = range
		}
		
	}
	
}
