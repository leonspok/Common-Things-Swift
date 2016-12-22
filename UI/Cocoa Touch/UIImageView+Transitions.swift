//
//  UIImageView+Transitions.swift
//  Commons
//
//  Created by Игорь Савельев on 22/12/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

import Foundation

extension UIImageView {
	func change(image: UIImage, transitionDuration: CFTimeInterval) {
		let transition = CATransition()
		transition.duration = transitionDuration
		transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
		transition.type = kCATransitionFade
		self.layer.add(transition, forKey: nil)
		self.image = image
	}
}
