//
//  FilterTableViewController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 9/25/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import UIKit
import PokeKit_iOS

class FilterTableViewController: UITableViewController {
	
	let allTypes = Type.allCases.sorted { (first, second) -> Bool in
		first.description < second.description
	}
	
	var allowedTypes: Set<Type> = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		switch section {
		case 0:
			return Type.allCases.count + 1
		default:
			return 0
		}
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 0:
				let cell = tableView.dequeueReusableCell(withIdentifier: "GenericCell", for: indexPath)
				
				cell.textLabel?.text = "Toggle All"
				
				return cell
			default:
				let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath) as! DamageTakenCell
				
				let type = allTypes[indexPath.row - 1]
				
				cell.typeLabel.text = type.description.uppercased()
				cell.typeView.backgroundColor = type.color
				cell.typeView.layer.cornerRadius = 4
				
				cell.accessoryType = allowedTypes.contains(type) ? .checkmark : .none
				
				return cell
			}
		default:
			return UITableViewCell()
		}
		
		
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 0:
				if allowedTypes == Set(allTypes) {
					allowedTypes.removeAll()
				} else {
					allowedTypes = Set(allTypes)
				}
				
				tableView.reloadRows(at: (1..<tableView.numberOfRows(inSection: 0)).map { IndexPath(row: $0, section: 0) }, with: .none)
				tableView.deselectRow(at: indexPath, animated: true)
			default:
				let type = allTypes[indexPath.row - 1]
				
				if allowedTypes.contains(type) {
					allowedTypes.remove(type)
				} else {
					allowedTypes.insert(type)
				}
				
				tableView.reloadRows(at: [indexPath], with: .automatic)
			}
		default:
			break
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Show Pokémon With These Types"
		default:
			return nil
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? PokemonListTableViewController, segue.identifier == "DoneSelecting" {
			destination.allowedTypes = self.allowedTypes
		}
	}

}
