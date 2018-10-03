//
//  MovesetTableViewController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 9/25/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import UIKit
import PokeKit_iOS
import AVFoundation

class MovesetTableViewController: UITableViewController, PokémonRepresentingController {

	var moveset: Moveset?
	
    override func viewDidLoad() {
        super.viewDidLoad()

		if let _ = pokémon {
			didUpdatePokémon()
		}
    }
	
	func didUpdatePokémon() {
		moveset = try? Moveset.moveset(for: pokémon)
		tableView?.reloadData()
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
		guard let _ = moveset else {
			return 0
		}
		
		return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moveset?.moves.count ?? 0
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Moves"
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoveInfoCell", for: indexPath)
		
		guard let info = moveset?.moves[indexPath.row] else {
			return cell
		}
		
        cell.textLabel?.text = info.moveName
		
		let method: String = {
			if info.method.uppercased().hasPrefix("L") {
				return info.method.uppercased().replacingOccurrences(of: "L", with: "Lv. ")
			} else {
				return info.method
			}
		}()
		
		cell.detailTextLabel?.text = method

        return cell
    }
	
	override func updateUserActivityState(_ activity: NSUserActivity) {
		activity.addUserInfoEntries(from: ["focus": Focus.moveset.rawValue])
		super.updateUserActivityState(activity)
	}
	
	func focus(on focus: Focus, speak: Bool) -> Bool {
		switch focus {
		case .moveset:
			tableView.setContentOffset(.zero, animated: true)
			if speak {
				siriSpeak("Here is \(pokémon.forme)'s moveset.")
			}
			return true
		case .move(let moveName):
			if let index = moveset?.moves.firstIndex(where: { $0.moveName.lowercased() == moveName.lowercased() }) {
				let indexPath = IndexPath(row: index, section: 0)
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
					self.tableView.deselectRow(at: indexPath, animated: true)
					self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
					
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
						self.tableView.deselectRow(at: indexPath, animated: true)
					}
				}
				
				if speak {
					let moveInfo = moveset!.moves.filter { $0.moveName.lowercased() == moveName.lowercased() }
					
					func verbalRepresentation(for method: String) -> String {
						if method.hasPrefix("L") {
							return "at level \(method[method.index(after: method.startIndex)...])"
						} else if method == "Start" {
							return "from the start"
						} else if method.hasPrefix("TM") {
							return "with \(method)"
						} else if method == "Egg" {
							return "through breeding"
						} else {
							return "through \(method)"
						}
					}
					
					let str: String
					
					switch moveInfo.count {
					case 1:
						str = "\(pokémon.forme) learns \(moveName) \(verbalRepresentation(for: moveInfo.first!.method))"
					default:
						var verbalRepresentations = moveInfo.map { verbalRepresentation(for: $0.method) }
						verbalRepresentations.insert("and", at: verbalRepresentations.count-1)
						let methods = verbalRepresentations.joined(separator: ", ").replacingOccurrences(of: "and,", with: "and")
						
						str = "\(pokémon.forme) learns \(moveName) \(methods)."
					}
					
					siriSpeak(str)
				}
				
				return true
			} else if speak {
				if Pokédex.allMoveNames.contains(where: { $0.lowercased() == moveName }) {
					let utterance = AVSpeechUtterance(string: "\(pokémon.forme) can't learn \(moveName).")
					
					let synthesizer = AVSpeechSynthesizer()
					synthesizer.speak(utterance)
				} else {
					siriSpeak("\(moveName) isn't a move.")
				}
			}
			
			return false
		default:
			return false
		}
	}

}
