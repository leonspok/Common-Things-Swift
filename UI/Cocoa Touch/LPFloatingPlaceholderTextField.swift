//
//  LPFloatingPlaceholderTextField.swift
//  Commons
//
//  Created by Игорь Савельев on 22/12/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

import UIKit

@IBDesignable
class LPFloatingPlaceholderTextField: UITextField {
	internal let floatingPlaceholderLabel = UILabel()
	internal let defaultPlaceholderLabel = UILabel()
	
	internal var isEmpty: Bool {
		get {
			guard let text = self.text else {
				return true;
			}
			return (text.characters.count == 0)
		}
	}
	
	@IBInspectable var floatDistance = 12.0 {
		didSet {
			self.updateLabelPositions()
		}
	}
	
	@IBInspectable var floatingPlaceholder: String? {
		didSet {
			self.floatingPlaceholderLabel.text = self.floatingPlaceholder
		}
	}
	
	@IBInspectable var defaultPlaceholderColor: UIColor? {
		didSet {
			self.defaultPlaceholderLabel.textColor = self.defaultPlaceholderColor
		}
	}
	@IBInspectable var defaultPlaceholderFont: UIFont? {
		didSet {
			self.defaultPlaceholderLabel.font = self.defaultPlaceholderFont
		}
	}
	
	@IBInspectable var floatingPlaceholderColor: UIColor? {
		didSet {
			self.floatingPlaceholderLabel.textColor = self.floatingPlaceholderColor
		}
	}
	@IBInspectable var floatingPlaceholderFont: UIFont? {
		didSet {
			self.floatingPlaceholderLabel.font = self.floatingPlaceholderFont
		}
	}
	
	// MARK: Overrides
	
	internal var wasEmpty = true
	override var text: String? {
		willSet {
			self.wasEmpty = self.isEmpty
		}
		didSet {
			let becomeEmpty = self.isEmpty
			if wasEmpty && !becomeEmpty {
				self.floatUp()
			} else if !wasEmpty && becomeEmpty {
				self.floatDown()
			}
 		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.buildView()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.buildView()
	}
	
	override func awakeFromNib() {
		self.buildView()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.updateLabelPositions()
	}
	
	internal func buildView() {
		self.clipsToBounds = true
		
		self.floatingPlaceholderLabel.font = self.floatingPlaceholderFont
		self.floatingPlaceholderLabel.textColor = self.floatingPlaceholderColor
		self.floatingPlaceholderLabel.text = self.floatingPlaceholder
		if !self.subviews.contains(self.floatingPlaceholderLabel) {
			self.insertSubview(self.floatingPlaceholderLabel, at: 0)
		}
		self.floatingPlaceholderLabel.isHidden = true
		
		self.defaultPlaceholderLabel.font = self.defaultPlaceholderFont
		self.defaultPlaceholderLabel.textColor = self.defaultPlaceholderColor
		self.defaultPlaceholderLabel.text = self.floatingPlaceholder
		if !self.subviews.contains(self.defaultPlaceholderLabel) {
			self.insertSubview(self.defaultPlaceholderLabel, at: 1)
		}
		
		self.updateLabelPositions()
		
		self.addTarget(self, action: #selector(editingStarted(sender:)), for: .editingDidBegin)
		self.addTarget(self, action: #selector(editingFinished(sender:)), for: .editingDidEnd)
	}
	
	// MARK: Actions
	
	internal func updateLabelPositions() {
		if !self.isFirstResponder && self.isEmpty {
			self.floatingPlaceholderLabel.frame = self.bounds
			self.defaultPlaceholderLabel.frame = self.bounds
		} else {
			let dist = self.floatDistance*(-2)
			self.floatingPlaceholderLabel.frame = self.bounds.applying(CGAffineTransform.init(translationX: 0, y: CGFloat(dist)))
			self.defaultPlaceholderLabel.frame = self.bounds.applying(CGAffineTransform.init(translationX: 0, y: CGFloat(dist)))
		}
	}
	
	internal func floatUp() {
		let dist = self.floatDistance*(-2)
		
		self.floatingPlaceholderLabel.isHidden = false
		self.floatingPlaceholderLabel.alpha = 0
		self.floatingPlaceholderLabel.transform = CGAffineTransform.identity
		self.transform = CGAffineTransform.identity
		
		UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: .allowAnimatedContent, animations: {
			self.floatingPlaceholderLabel.alpha = 1
			self.floatingPlaceholderLabel.transform = CGAffineTransform.init(translationX: 0, y: CGFloat(dist))
			self.defaultPlaceholderLabel.alpha = 0
			self.defaultPlaceholderLabel.transform = CGAffineTransform.init(translationX: 0, y: CGFloat(dist))
		}) { (result: Bool) in
			self.defaultPlaceholderLabel.isHidden = true
		}
	}
	
	internal func floatDown() {
		let dist = self.floatDistance*(-2)
		
		self.defaultPlaceholderLabel.isHidden = false
		self.defaultPlaceholderLabel.alpha = 0
		self.defaultPlaceholderLabel.transform = CGAffineTransform.init(translationX: 0, y: CGFloat(dist))
		self.transform = CGAffineTransform.init(translationX: 0, y: CGFloat(self.floatDistance))
		
		UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: .allowAnimatedContent, animations: {
			self.floatingPlaceholderLabel.alpha = 0
			self.floatingPlaceholderLabel.transform = CGAffineTransform.identity
			self.defaultPlaceholderLabel.alpha = 1
			self.defaultPlaceholderLabel.transform = CGAffineTransform.identity
			self.transform = CGAffineTransform.identity
		}) { (result: Bool) in
			self.floatingPlaceholderLabel.isHidden = true
		}
	}
	
	internal func editingStarted(sender: AnyObject) {
		if self.isEmpty {
			self.floatUp()
		}
	}
	
	internal func editingFinished(sender: AnyObject) {
		if self.isEmpty {
			self.floatDown()
		}
	}
}
