//
//  InterfaceController.swift
//  Super Effective WatchKit Extension
//
//  Created by Josh Birnholz on 11/24/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation
import SwiftyJSON

let pokemonNames: [PokémonInfo] = {
	let namesURL = Bundle.main.url(forResource: "pokemonnames", withExtension: "json")!
	let namesJSONString = try! String(contentsOf: namesURL)
	let namesJSON = JSON.parse(namesJSONString)
	
	return namesJSON.array!.flatMap( { PokémonInfo.init(json: $0) } )
}()

class InterfaceController: WKInterfaceController {
	
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
	
}
