//
//  RootSplitViewController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 9/26/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import UIKit

class RootSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		self.preferredDisplayMode = .allVisible
        // Do any additional setup after loading the view.
    }
	
	override func restoreUserActivityState(_ activity: NSUserActivity) {
		switch activity.activityType {
		case "com.josh.birnholz.SuperEffective.ViewPokemon":
			if let list = (viewControllers.first as? UINavigationController)?.viewControllers.first as? PokemonListTableViewController {
				list.performSegue(withIdentifier: "ShowPokemon", sender: activity)
			}
		default:
			break
		}
	}

}
