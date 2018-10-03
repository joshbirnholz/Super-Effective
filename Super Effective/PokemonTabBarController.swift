//
//  PokemonTabBarController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 9/24/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import UIKit
import PokeKit_iOS
import Intents

class PokemonTabBarController: UITabBarController, PokémonRepresentingController {

	@IBOutlet weak var changeFormButton: UIBarButtonItem!
	
	var pokémon: Pokémon! {
		didSet {
			if isViewLoaded {
				didUpdatePokémon()
			} else {
				configureNavigation()
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if let _ = pokémon {
			didUpdatePokémon()
		}
    }
    
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		guard let pokémon = pokémon else { return }
		
		updateRecents(withID: pokémon.id)
		
		self.userActivity = pokémon.userActivity
		self.userActivity?.becomeCurrent()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		self.userActivity?.invalidate()
	}
	
	private func configureNavigation() {
		guard let pokémon = pokémon else {
			navigationItem.rightBarButtonItem = nil
			navigationItem.prompt = nil
			navigationItem.title = nil
			return
		}
		
		if pokémon.altFormIDs.count > 1 {
			navigationItem.rightBarButtonItem = changeFormButton
		} else {
			navigationItem.rightBarButtonItem = nil
		}
		
		if !pokémon.formName.isEmpty {
			navigationItem.prompt = pokémon.formName
		} else {
			navigationItem.prompt = nil
		}
		
		navigationItem.title = pokémon.name
	}
	
	func didUpdatePokémon() {
		
		configureNavigation()
		
		for vc in viewControllers ?? [] where vc.isViewLoaded {
			(vc as? PokémonRepresentingController)?.didUpdatePokémon()
		}
		
		userActivity = pokémon.userActivity
		userActivity?.needsSave = true
	}
	
	@IBAction func presentFormPicker() {
		
		let optionsPicker = OptionsPickerViewController(title: "Forms", key: "formpicker", options: pokémon.altFormIDs, selectedOption: pokémon.id)
		
		optionsPicker.optionsStrings = pokémon.altFormIDs.map {
			Pokédex.allPokémonInfo[$0]?.form ?? "???"
		}
		
		optionsPicker.cellCustomizations = { id, cell in
			cell.imageView?.image = Pokédex.allPokémonInfo[id]?.icon
		}
		
		optionsPicker.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: optionsPicker, action: #selector(optionsPicker.cancel))
		
		optionsPicker.returnsWhenSelected = true
		
		optionsPicker.delegate = self
		
		let nav = UINavigationController(rootViewController: optionsPicker)
		
		nav.modalPresentationStyle = .popover
		nav.popoverPresentationController?.barButtonItem = changeFormButton
		
		present(nav, animated: true, completion: nil)
		
	}
	
	override func restoreUserActivityState(_ activity: NSUserActivity) {
		switch activity.activityType {
		case "com.josh.birnholz.SuperEffective.ViewPokemon":
			if let id = activity.userInfo?["id"] as? Int, let pk = Pokémon.with(id: id) {
				self.pokémon = pk
			}
			
			let speak = activity.userInfo?["speak"] as? Bool ?? false
			activity.addUserInfoEntries(from: ["speak": false])
			
			if let focus = (activity.userInfo?["focus"] as? String).flatMap(Focus.init) {
				self.focus(on: focus, speak: speak)
			}
		default:
			break
		}
	}
	
	@discardableResult func focus(on focus: Focus, speak: Bool) -> Bool {
		selectedIndex = focus.tabIndex
		
		return (viewControllers?[focus.tabIndex] as? PokémonRepresentingController)?.focus(on: focus, speak: speak) ?? false
	}
	
	override func updateUserActivityState(_ activity: NSUserActivity) {
		activity.addUserInfoEntries(from: pokémon.userActivity.userInfo ?? [:])
		selectedViewController?.updateUserActivityState(activity)
	}
	
	override var selectedIndex: Int {
		didSet {
			userActivity?.needsSave = true
		}
	}

}

fileprivate extension Focus {
	var tabIndex: Int {
		switch self {
		case .basicDetail:
			return 0
		case .moveset, .move:
			return 1
		case .damageTaken, .superEffective, .notVeryEffective, .noEffect:
			return 2
		case .evolution:
			return 3
		}
	}
}

extension PokemonTabBarController: OptionsPickerViewControllerDelegate {
	func optionsPicker<T>(didSelect option: T, for key: String?) where T : Equatable {
		guard let id = option as? Int, let pk = Pokémon.with(id: id) else {
			return
		}
		
		self.pokémon = pk
	}
	
}

// MARK: UIStateRestoring

extension PokemonTabBarController {
	
	override func encodeRestorableState(with coder: NSCoder) {
		coder.encode(pokémon.id, forKey: "id")
		
		super.encodeRestorableState(with: coder)
	}
	
	override func decodeRestorableState(with coder: NSCoder) {
		super.decodeRestorableState(with: coder)
		if let pk = Pokémon.with(id: coder.decodeInteger(forKey: "id")), coder.containsValue(forKey: "id") {
			self.pokémon = pk
		}
		
	}
	
}
