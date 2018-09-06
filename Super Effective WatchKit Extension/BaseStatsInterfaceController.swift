//
//  BaseStatsInterfaceController.swift
//  Super Effective
//
//  Created by Josh Birnholz on 12/9/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import WatchKit
import NKWatchChart
import PokeKit

class BaseStatsInterfaceController: PokémonRepresentingInterfaceController {
	
	@IBOutlet var statsChartImage: WKInterfaceImage!
	@IBOutlet var totalStatsLabel: WKInterfaceLabel!
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
		guard let pokémon = context as? Pokémon else { return }
		
		self.pokémon = pokémon
		
		setTitle(pokémon.name)
		
		loadBaseStatsChart()
		totalStatsLabel.setText("Base Stat Total: \(pokémon.total)")
	}
	
	func loadBaseStatsChart() {
		var items = [NKRadarChartDataItem]()
		items.append(NKRadarChartDataItem(value: CGFloat(pokémon.attack), description: "Attack\n\(pokémon.attack)"))
		items.append(NKRadarChartDataItem(value: CGFloat(pokémon.defense), description: "Defense\n\(pokémon.defense)"))
		items.append(NKRadarChartDataItem(value: CGFloat(pokémon.spdefense), description: "Sp. Def\n\(pokémon.spdefense)"))
		items.append(NKRadarChartDataItem(value: CGFloat(pokémon.spattack), description: "Sp. Atk\n\(pokémon.spattack)"))
		items.append(NKRadarChartDataItem(value: CGFloat(pokémon.speed), description: "Speed\n\(pokémon.speed)"))
		items.append(NKRadarChartDataItem(value: CGFloat(pokémon.hp), description: "HP\n\(pokémon.hp)"))
		
		let frame = CGRect(x: 0, y: 0, width: contentFrame.size.width, height: contentFrame.size.height - 30)
		
		let chart = NKRadarChart(frame: frame, items: items, valueDivider: 50)
		
		chart?.webColor = UIColor(white: 1, alpha: 0.2)
		chart?.maxValue = 200
		
		chart?.fontSize = 9
		
		let image = chart?.drawImage()
		statsChartImage.setImage(image)
		
	}
	
}
