//
//  JSONConvertable.swift
//  Commons
//
//  Created by Игорь Савельев on 12/12/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

import Foundation

protocol JSONConvertable {
	init(withJSON json: [String : AnyObject])
	func update(withJSON json: [String : AnyObject])
	
	static func createObjects(fromJSONObjects jsonObjects: [AnyObject]) -> [Self]
}
