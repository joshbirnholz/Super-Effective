//
//  MoveDetailInterfaceController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 11/26/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation
import PokeKit

class MoveDetailInterfaceController: WKInterfaceController {
	
	@IBOutlet var typeButton: WKInterfaceButton!
	@IBOutlet var categoryButton: WKInterfaceGroup!
	@IBOutlet var categoryImage: WKInterfaceImage!
	@IBOutlet var powerLabel: WKInterfaceLabel!
	@IBOutlet var accuracyLabel: WKInterfaceLabel!
	@IBOutlet var descriptionLabel: WKInterfaceLabel!
	@IBOutlet var ppLabel: WKInterfaceLabel!
	@IBOutlet var zmoveEffectLabel: WKInterfaceLabel!
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
		guard let moveName = context as? String else {
			print("Couldn't read move name")
			return
		}
		
		guard let move = Move.with(name: moveName) else {
				print("Couldn't read plist")
				return
		}
		
		setTitle(move.name)
		typeButton.setTitle(move.type.rawValue.uppercased())
		typeButton.setBackgroundColor(move.type.color)
		
		categoryButton.setBackgroundColor(move.category.color)
		categoryImage.setImage(move.category.symbol)
		
		if let power = move.power, power != 0 {
			powerLabel.setText(String(power))
		} else {
			powerLabel.setText("—")
		}
		
		accuracyLabel.setText(move.accuracy)
		ppLabel.setText(String(move.pp))
		descriptionLabel.setText(move.description)
		zmoveEffectLabel.setText(move.zEffect)
		
	}
	
	@IBAction func okButtonPressed() {
		dismiss()
	}
}
