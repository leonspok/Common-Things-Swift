//
//  LPResizingLayersView.swift
//  Commons
//
//  Created by Игорь Савельев on 22/12/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

import UIKit

class LPResizingLayersView: UIView {
	private(set) var resizingLayers = [CALayer]()
	
	func add(resizingLayer: CALayer) {
		if self.resizingLayers.contains(resizingLayer) {
			return
		}
		resizingLayer.frame = self.bounds
		self.layer.addSublayer(resizingLayer)
		resizingLayers.append(resizingLayer)
	}
	
	func remove(resizingLayer: CALayer) {
		if !self.resizingLayers.contains(resizingLayer) {
			return
		}
		resizingLayer.removeFromSuperlayer()
		if let index = self.resizingLayers.index(of: resizingLayer) {
			self.resizingLayers.remove(at: index)
		}
	}
	
	override func layoutSublayers(of layer: CALayer) {
		if layer == self.layer {
			for l in self.resizingLayers {
				l.frame = self.bounds
			}
		}
	}
}
