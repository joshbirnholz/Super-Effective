//
//  TypedInterfaceController.swift
//  Super Effective WatchKit Extension
//
//  Created by Josh Birnholz on 9/7/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation

class TypedInterfaceController<T>: WKInterfaceController {

	override init() {
		super.init()
		NSObject.load()
	}

	override final func awake(withContext context: Any?) {
		guard let typedContext = context as? T else {
			awake(withIncorrectContext: context)
			return
		}

		awake(with: typedContext)
	}

	func awake(with context: T) {

	}

	func awake(withIncorrectContext context: Any?) {

	}

}
