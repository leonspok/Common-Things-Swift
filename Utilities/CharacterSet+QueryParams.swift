//
//  CharacterSet+QueryParams.swift
//  Commons
//
//  Created by Игорь Савельев on 12/12/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

import Foundation

extension CharacterSet  {
	public static var urlQueryParameterValueAllowed : CharacterSet {
		get {
			let generalDelimitersToEncode = ":#[]@"
			let subDelimitersToEncode = "!$&'()*+,;="
			let allDelimitersToEncode = generalDelimitersToEncode + subDelimitersToEncode
			
			var allowedCharacterSet = CharacterSet.urlQueryAllowed;
			allowedCharacterSet.remove(charactersIn: allDelimitersToEncode)
			
			return allowedCharacterSet
		}
	}
}
