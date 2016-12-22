//
//  AttributedString+Sizing.swift
//  Commons
//
//  Created by Игорь Савельев on 22/12/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

import Foundation

extension NSAttributedString {
	func size(constraintedTo constraintSize: CGSize) -> CGSize {
		let textContainer = NSTextContainer.init(size: constraintSize)
		let layoutManager = NSLayoutManager()
		layoutManager.addTextContainer(textContainer)
		let textStorage = NSTextStorage.init(attributedString: self)
		textStorage.addLayoutManager(layoutManager)
		var outputRect = layoutManager.usedRect(for: textContainer)
		outputRect = outputRect.integral
		return outputRect.size
	}
}
