//
//  LPRoundRectButton.swift
//  Commons
//
//  Created by Игорь Савельев on 22/12/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

import UIKit

@IBDesignable
class LPRoundRectButton: UIButton {
	@IBInspectable var cornerRadius: CGFloat? {
		didSet {
			if let radius = self.cornerRadius {
				self.layer.cornerRadius = radius
			} else {
				self.layer.cornerRadius = 0
			}
		}
	}
	@IBInspectable var borderWidth: CGFloat? {
		didSet {
			if let width = self.borderWidth {
				self.layer.borderWidth = width
			} else {
				self.layer.borderWidth = 0
			}
		}
	}
	
	internal var backgroundColors = [UInt : UIColor]()
	internal var borderColors = [UInt : UIColor]()
	
	public func set(backgroundColor: UIColor, for state: UIControlState) {
		self.backgroundColors[state.rawValue] = backgroundColor
		self.makeChanges(for: state)
	}
	
	public func set(borderColor: UIColor, for state: UIControlState) {
		self.borderColors[state.rawValue] = borderColor
		self.makeChanges(for: state)
	}
	
	// MARK: States handling
	
	internal func makeChanges(for state: UIControlState) {
		self.backgroundColor = self.backgroundColors[state.rawValue]
		self.layer.borderColor = self.borderColors[state.rawValue]?.cgColor
	}
	
	// MARK : Observing state changes
	
	override var isSelected : Bool {
		didSet {
			self.makeChanges(for: self.state)
		}
	}
	
	override var isHighlighted: Bool {
		didSet {
			self.makeChanges(for: self.state)
		}
	}
	
	override var isEnabled: Bool {
		didSet {
			self.makeChanges(for: self.state)
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		self.makeChanges(for: self.state)
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		self.makeChanges(for: self.state)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		self.makeChanges(for: self.state)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		self.makeChanges(for: self.state)
	}
}
