//
//  Dictionary+URL.swift
//  Commons
//
//  Created by Игорь Савельев on 12/12/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

import Foundation

extension Dictionary {
	public static func build(with url: URL) -> Dictionary<String, String> {
		let queryString = url.query
		let parameters = queryString?.components(separatedBy: "&")
		var result : [String : String] = [:]
		guard parameters != nil else {
			return result
		}
		for parameter : String in parameters! {
			let parts = parameter.components(separatedBy: "=")
			guard parts.count >= 2 else {
				continue
			}
			let key = parts[0]
			let value = parts[1]
			result[key] = value
		}
		return result
	}
}
