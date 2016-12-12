//
//  Array+Shuffle.swift
//  Commons
//
//  Created by Игорь Савельев on 12/12/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

import Foundation

extension Array {
	public mutating func shuffle() {
		let count = self.count
		guard count > 0 else {
			return
		}
		for i in 1..<count {
			let remainingCount = count-i
			let exchangeIndex = i + Int(arc4random_uniform(UInt32(remainingCount)))
			let temp = self[i]
			self[i] = self[exchangeIndex]
			self[exchangeIndex] = temp
		}
	}
}
