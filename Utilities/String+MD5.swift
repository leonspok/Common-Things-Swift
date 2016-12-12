//
//  String+MD5.swift
//  Commons
//
//  Created by Игорь Савельев on 12/12/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

import Foundation

// Requires Bridging Header for #import "CommonCrypto/CommonCrypto.h"

extension String {
	public func md5() -> String? {
		let digestLength = Int(CC_MD5_DIGEST_LENGTH)
		var digest = [UInt8](repeating: 0, count: digestLength)
		
		if let d = self.data(using: String.Encoding.utf8) {
			_ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
				CC_MD5(body, CC_LONG(d.count), &digest)
			}
		}
		
		return (0..<digestLength).reduce("") {
			$0 + String(format: "%02x", digest[$1])
		}
	}
}
