//
//  TypeCheckerInterfaceController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 12/24/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import WatchKit
import PokeKit

class TypeCheckerInterfaceController: WKInterfaceController {
	
	@IBOutlet var type1Picker: WKInterfacePicker!
	@IBOutlet var type2Picker: WKInterfacePicker!
	@IBOutlet var checkButton: WKInterfaceButton!
	
	let types = Type.allCases.sorted(by: { $0.rawValue < $1.rawValue })
	
	var type1: Type = .bug
	var type2: Type?
	
	override func awake(withContext context: Any?) {

		let type1Items: [WKPickerItem] = types.map {
			let item = WKPickerItem()
			item.title = $0.rawValue.capitalized
			item.caption = "Type 1"
			return item
		}
		
		let type2Items: [WKPickerItem] = {
			var typeItems: [WKPickerItem] = types.map {
				let item = WKPickerItem()
				item.title = $0.rawValue.capitalized
				item.caption = "Type 2"
				return item
			}
			let noneItem = WKPickerItem()
			noneItem.title = ""
			noneItem.caption = "Type 2"
			
			typeItems.insert(noneItem, at: 0)
			return typeItems
		}()
		
		type1Picker.setItems(type1Items)
		type2Picker.setItems(type2Items)
		
	}
	
	@IBAction func type1PickerValueChanged(_ value: Int) {
		type1 = types[value]
		updateButton()
	}
	
	@IBAction func type2PickerValueChanged(_ value: Int) {
		if value == 0 {
			type2 = nil
		} else {
			type2 = types[value - 1]
		}
		updateButton()
	}
	
	func updateButton() {
		checkButton.setEnabled(type1 != type2)
	}
	
	override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
		if segueIdentifier == "TypeMatchupSegue" {
			let combo = TypeCombination(type1, type2)
			return [combo.description, combo]
		} else {
			return nil
		}
	}
	
}
