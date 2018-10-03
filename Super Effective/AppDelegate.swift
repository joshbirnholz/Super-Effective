//
//  AppDelegate.swift
//  Super Effective
//
//  Created by Josh Birnholz on 11/24/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import UIKit
import PokeKit_iOS
import MBProgressHUD
import AVFoundation

extension UIViewController {
	func siriSpeak(_ text: String) {
		let utterance = AVSpeechUtterance(string: text)
		
		let synthesizer = AVSpeechSynthesizer()
		synthesizer.speak(utterance)
		
		print("Speaking:", text)
		
//		let hud = MBProgressHUD.showAdded(to: view, animated: true)
//		hud.mode = .text
//		hud.label.text = text
//		hud.offset = CGPoint(x: 0, y: MBProgressMaxOffset)
//		hud.hide(animated: true, afterDelay: 3)
	}
}

enum Focus: RawRepresentable, Equatable {
	typealias RawValue = String
	
	case damageTaken
	case superEffective
	case notVeryEffective
	case noEffect
	case moveset
	case basicDetail
	case evolution
	case move(name: String)
	
	init?(rawValue: String) {
		switch rawValue {
		case "damageTaken":
			self = .damageTaken
		case "moveset":
			self = .moveset
		case "basicDetail":
			self = .basicDetail
		case _ where rawValue.hasPrefix("moveName-"):
			let moveName = String(rawValue[rawValue.index(rawValue.startIndex, offsetBy: 9)...])
			self = .move(name: moveName)
		case "superEffective":
			self = .superEffective
		case "notVeryEffective":
			self = .notVeryEffective
		case "noEffect":
			self = .noEffect
		case "evolution":
			self = .evolution
		default:
			return nil
		}
	}
	
	var rawValue: String {
		switch self {
		case .damageTaken: return "damageTaken"
		case .superEffective: return "superEffective"
		case .notVeryEffective: return "notVeryEffective"
		case .noEffect: return "noEffect"
		case .moveset: return "moveset"
		case .basicDetail: return "basicDetail"
		case .move(let name): return "moveName-\(name)"
		case .evolution: return "evolution"
		}
	}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	func application(_ application: UIApplication, show pokémon: Pokémon, focus: Focus?, speak: Bool) -> Bool {
		let userActivity = pokémon.userActivity
		if let focus = focus {
			userActivity.addUserInfoEntries(from: ["focus": focus.rawValue])
		}
		userActivity.addUserInfoEntries(from: ["speak": speak])
		return self.application(application, continue: userActivity, restorationHandler: { _ in })
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		(window?.rootViewController as? UISplitViewController)?.delegate = self
		
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
		return true
	}
	
	func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
		return true
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return false }
		
		let speak = components.queryItems?["speak"] == "true"
		
		let masterTableVC: PokemonListTableViewController? = (((window?.rootViewController as? RootSplitViewController)?.viewControllers.first as? UINavigationController)?.viewControllers.first as? PokemonListTableViewController)
		
		/// The Pokémon specified by "`id`", "`name`", or "`ndex`" in the URL query, or `nil` if none is specified.
		var pokémon: Pokémon? {
			if let pokémon = components.queryItems?["id"].flatMap(Int.init).flatMap({ Pokémon.with(id: $0) }) {
				return pokémon
			} else if let pokémon = components.queryItems?["name"].flatMap({ name in Pokédex.allPokémonInfo.values.sorted { $0.id < $1.id }.first { $0.name.lowercased() == name.lowercased() } }).flatMap({ Pokémon.with(id: $0.id) }) {
				return pokémon
			} else if let pokémon = components.queryItems?["ndex"].flatMap(Int.init).flatMap({ dexNo in Pokédex.allPokémonInfo.values.sorted { $0.id < $1.id }.first { $0.ndex == dexNo } }).flatMap({ Pokémon.with(id: $0.id) }) {
				return pokémon
			}
			return nil
		}
		
		switch components.host {
		case "pokemon":
			let focus = components.queryItems?["focus"].flatMap(Focus.init)
			
			if let pokémon = pokémon {
				return application(app, show: pokémon, focus: focus, speak: speak)
			}
			
			break
		case "move":
			if let moveName = components.queryItems?["name"] {
				return masterTableVC?.showMove(named: moveName, speak: speak) ?? false
			}
		default:
			break
		}
		
		return false
	}
	
	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
		if let window = self.window {
			window.rootViewController?.restoreUserActivityState(userActivity)
		}
		return true
	}

	func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
		return userActivityType == "com.josh.birnholz.SuperEffective.ViewPokemon"
	}

}

extension AppDelegate: UISplitViewControllerDelegate {
	
	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
		
		if let tabBarVC = ((secondaryViewController as? UINavigationController)?.topViewController as? PokemonTabBarController) {
			return tabBarVC.pokémon == nil
		} else {
			return true
		}
	}
}
