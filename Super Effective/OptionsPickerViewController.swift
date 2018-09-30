//
//  OptionsPickerViewController.swift
//  Countdowns
//
//  Created by Josh Birnholz on 10/17/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import UIKit

public protocol OptionsPickerViewControllerDelegate: class {
	func optionsPicker <T: Equatable> (didSelect option: T, for key: String?)
}

public class OptionsPickerViewController<T: Equatable>: UITableViewController {
	
	public weak var delegate: OptionsPickerViewControllerDelegate?
	
	/// If this value is true, the table view controller is automatically popped from its navigation controller's stack or dismissed when an option is selected by the user.
	///
	/// The default value of this property is `false`.
	public var returnsWhenSelected = false
	
	/// The header text of the table view section.
	public var header: String?
	
	/// The footer text of the table view section.
	public var footer: String?
	
	/// A key used to identify this instance of class to the delegate.
	public let key: String?
	
	/// The options selectable by the user.
	public let options: [T]
	
	/// An array of `String`s used to display the options to the user.
	///
	/// By default, these are just the `String` representations of the items themselves. `Enum` case names are automatically capitalized.
	public var optionsStrings: [String]
	
	private let initialSelectedIndex: Int
	
	/// The index of the currently selected option.
	public var selectedIndex: Int
	
	/// A closure called during `tableView(_:cellForRowAt:)` that can be used for further customization of the cell.
	public var cellCustomizations: ((T, UITableViewCell) -> Void)?
	
	/// Creates and initializes a new `OptionsPickerViewController`.
	///
	/// - parameter title:                The title of the view controller displayed on the navigation bar.
	/// - parameter key:                  A key used to identify the option. If no key is specified, the `title` will be used.
	/// - parameter options:              The list of options to display.
	/// - parameter selectedOption:       The initial option to mark as selected. If this option is not included in the `options` array, the first option will be marked as selected.
	///
	/// - returns: A newly initialized `OptionsPickerViewController`.
	public init(title: String, key: String? = nil, options: [T], selectedOption: T) {
		self.options = options
		self.selectedIndex = options.index(of: selectedOption) ?? 0
		self.initialSelectedIndex = selectedIndex
		self.key = key ?? title
		self.optionsStrings = {
			if !(selectedOption is CustomStringConvertible), let displayStyle = Mirror(reflecting: selectedOption).displayStyle, displayStyle == .enum {
				return options.map { String(describing: $0).capitalized }
			} else {
				return options.map { String(describing: $0) }
			}
		}()
		super.init(style: .grouped)
		navigationItem.title = title
	}
	
	public required init?(coder aDecoder: NSCoder) {
		self.options = []
		self.selectedIndex = 0
		self.initialSelectedIndex = 0
		self.key = nil
		self.optionsStrings = []
		super.init(style: .grouped)
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "optionCell")
		if #available(iOS 11.0, *) {
			navigationItem.largeTitleDisplayMode = .never
		}
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		delegate?.optionsPicker(didSelect: options[selectedIndex], for: key)
	}
	
	public override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return options.count
	}
	
	public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return header
	}
	
	public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return footer
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
		
		cell.textLabel?.text = optionsStrings[indexPath.row]
		
		if selectedIndex == indexPath.row {
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
		
		cellCustomizations?(options[indexPath.row], cell)
		
		return cell
	}
	
	public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if returnsWhenSelected {
			selectedIndex = indexPath.row
			if navigationController?.popViewController(animated: true) == nil {
				dismiss(animated: true, completion: nil)
			}
			return
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		tableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0))?.accessoryType = .none
		tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
		
		selectedIndex = indexPath.row
		
		
	}
	
	@objc public func cancel() {
		dismiss(animated: true, completion: nil)
	}
	
}
