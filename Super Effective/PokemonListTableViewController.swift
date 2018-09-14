//
//  PokemonListTableViewController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 11/24/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import UIKit
import PokeKit_iOS

class PokemonListCell: UITableViewCell {
	
	@IBOutlet weak var iconImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var numberLabel: UILabel!
	
}

class PokemonListTableViewController: UITableViewController {
	
	private var searchController = UISearchController(searchResultsController: nil)
	
	var pokedexRange: PokédexRange! {
		didSet {
			navigationItem.title = pokedexRange.title
			pokemon = pokedexRange.dexNumbers.compactMap { id in
				Pokédex.allPokémonInfo[safe: id]
			}
		}
	}
	
	private var pokemon: [PokémonInfo] = []
	private var filteredPokemon: [PokémonInfo] = []
	
	private var activePokemonArray: [PokémonInfo] {
		return searchController.isActive && searchController.searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines) != "" ? filteredPokemon : pokemon
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if pokedexRange == nil {
			pokedexRange = PokédexRange(dexNumbers: Array(0...Pokédex.lastUniquePokémonID), title: "Pokédex")
		}
		
		searchController.searchResultsUpdater = self
		tableView.tableHeaderView = searchController.searchBar
		searchController.dimsBackgroundDuringPresentation = false
		definesPresentationContext = true
		tableView.keyboardDismissMode = .onDrag
		
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return activePokemonArray.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PokeCell", for: indexPath) as! PokemonListCell
		
		let info = activePokemonArray[indexPath.row]
		
		cell.iconImageView.image = info.icon
		cell.nameLabel.text = info.name
		cell.numberLabel.text = String(format: "%03d", info.ndex)
		
		return cell
		
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let info = activePokemonArray[indexPath.row]
		
		let pktvc = storyboard?.instantiateViewController(withIdentifier: "PokemonListTableViewController") as? PokemonListTableViewController
		pktvc?.pokedexRange = PokédexRange(dexNumbers: [info.id], title: info.form)
		
		navigationController?.pushViewController(pktvc!, animated: true)
	}
	
	func filterContent(searchText: String) {
		filteredPokemon = pokemon.filter { info in
			info.form.lowercased().contains(searchText.lowercased()) || String(info.ndex).hasPrefix(searchText)
		}
		tableView.reloadData()
	}

}

extension PokemonListTableViewController: UISearchResultsUpdating {
	
	func updateSearchResults(for searchController: UISearchController) {
		filterContent(searchText: searchController.searchBar.text!)
	}
	
}
