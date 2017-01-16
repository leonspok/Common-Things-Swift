//
//  UIImage+LPEffects.swift
//  Commons
//
//  Created by Игорь Савельев on 22/12/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

import UIKit

extension UIImage {
	
	func applyTint(color: UIColor) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
		defer {
			UIGraphicsEndImageContext()
		}
		
		guard let context = UIGraphicsGetCurrentContext() else {
			return nil
		}
		context.translateBy(x: 0, y: self.size.height)
		context.scaleBy(x: 1.0, y: -1.0)
		
		let rect = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
		
		context.setBlendMode(.normal)
		color.setFill()
		context.fill(rect)
		
		context.setBlendMode(.destinationIn)
		guard let cgImage = self.cgImage else {
			return nil
		}
		context.draw(cgImage, in: rect)
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
	
		return image
	}
	
	func scaledImage(size: CGSize) -> UIImage? {
		let width = self.size.width
		let height = self.size.height
		
		let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		
		let drawRect: CGRect
		let verticalScaleRatio = frame.size.height/height
		let horizontalScaleRatio = frame.size.width/width
		
		if verticalScaleRatio > horizontalScaleRatio {
			let newWidth = width * verticalScaleRatio
			let offset = (newWidth - frame.size.width)/2
			drawRect = CGRect(x: -offset, y: 0, width: newWidth, height: frame.size.height)
		} else {
			let newHeight = height * horizontalScaleRatio
			let offset = (newHeight - frame.size.height)/2
			drawRect = CGRect(x: 0, y: -offset, width: frame.size.width, height: newHeight)
		}
		
		UIGraphicsBeginImageContext(frame.size)
		defer {
			UIGraphicsEndImageContext()
		}
		
		self.draw(in: drawRect)
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		return scaledImage
	}
	
	func roundedImage(size: CGSize) -> UIImage? {
		let width = self.size.width
		let height = self.size.height
		
		let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		
		let drawRect: CGRect
		let verticalScaleRatio = frame.size.height/height
		let horizontalScaleRatio = frame.size.width/width
		
		if verticalScaleRatio > horizontalScaleRatio {
			let newWidth = width * verticalScaleRatio
			let offset = (newWidth - frame.size.width)/2
			drawRect = CGRect(x: -offset, y: 0, width: newWidth, height: frame.size.height)
		} else {
			let newHeight = height * horizontalScaleRatio
			let offset = (newHeight - frame.size.height)/2
			drawRect = CGRect(x: 0, y: -offset, width: frame.size.width, height: newHeight)
		}
		
		UIGraphicsBeginImageContext(frame.size)
		defer {
			UIGraphicsEndImageContext()
		}
		
		UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: size), cornerRadius: size.height/2).addClip()
		self.draw(in: drawRect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		return newImage
	}
}
