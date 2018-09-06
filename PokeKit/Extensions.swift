//
//  Extensions.swift
//  Super Effective
//
//  Created by Josh Birnholz on 12/22/16.
//  Copyright © 2016 Joshua Birnholz. All rights reserved.
//

import Foundation

public extension Array {
	public subscript (safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}

	public func chunked(by chunkSize: Int) -> [[Element]] {
		return stride(from: 0, to: self.count, by: chunkSize).map {
			Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
		}
	}
}
