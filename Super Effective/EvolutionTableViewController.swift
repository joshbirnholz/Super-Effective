//
//  EvolutionTableViewController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 10/2/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import UIKit
import PokeKit_iOS

class EvolutionTableViewController: UITableViewController, PokémonRepresentingController {

    override func viewDidLoad() {
        super.viewDidLoad()

		if let _ = pokémon {
			didUpdatePokémon()
		}
    }
	
	func didUpdatePokémon() {
		tableView.reloadData()
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pokémon.evolutionTree.count
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Evolution"
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "evoCell", for: indexPath)
		
		let evolution = pokémon.evolutionTree[indexPath.row]

		guard let sourcePokémonInfo = Pokédex.allPokémonInfo[evolution.originalSpeciesID],
			let evolvedPokémonInfo = Pokédex.allPokémonInfo[evolution.evolvedSpeciesID] else {
				return cell
		}
		
		var text = ""
		
		if indexPath.row > 0 && pokémon.evolutionTree[indexPath.row - 1].evolvedSpeciesID == evolution.originalSpeciesID {
		} else {
			text += sourcePokémonInfo.form + " "
		}
		
		text += "➜ \(evolvedPokémonInfo.form)"
		
		cell.textLabel?.text = text
		cell.detailTextLabel?.text = evolution.conditions

        return cell
    }
	
	func focus(on focus: Focus, speak: Bool) -> Bool {
		switch focus {
		case .evolution:
			let index = pokémon.evolutionTree.firstIndex(where: { $0.originalSpeciesID == pokémon.id }) ?? NSNotFound
			tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .top)
			
			if speak {
				var evolutions = pokémon.evolutionTree.filter { $0.originalSpeciesID == pokémon.id }.map { "into \(Pokédex.allPokémonInfo[$0.evolvedSpeciesID]?.form ?? "???") \($0.conditions)" }
				
				switch evolutions.count {
				case 0:
					siriSpeak("\(pokémon.forme) doesn't evolve.")
				case 1:
					siriSpeak("\(pokémon.forme) evolves \(evolutions[0]).")
				default:
					evolutions.insert("and", at: evolutions.count-1)
					let str = "\(pokémon.forme) evolves \(evolutions.joined(separator: ", ").replacingOccurrences(of: "and,", with: "and"))"
					siriSpeak(str)
				}
			}
			
			return true
		default:
			return false
		}
		
	}

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
