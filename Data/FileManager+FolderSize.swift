//
//  FileManager+FolderSize.swift
//  Commons
//
//  Created by Игорь Савельев on 12/12/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

import Foundation

extension FileManager {
	func folderSize(url: URL) -> NSNumber {
		let prefetchedProperties = [URLResourceKey.isRegularFileKey,
		                            URLResourceKey.fileAllocatedSizeKey,
		                            URLResourceKey.totalFileAllocatedSizeKey,
		                            URLResourceKey.isDirectoryKey]
		let dirEnumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: prefetchedProperties, options: .init(rawValue: 0), errorHandler: nil)
		var size : UInt64 = 0
		dirEnumerator?.forEach({ (contentURL) in
			guard let url = contentURL as? NSURL else {
				return
			}
			
			var isDirectoryValue : AnyObject?
			do {
				try url.getResourceValue(&isDirectoryValue, forKey: URLResourceKey.isDirectoryKey)
			} catch _ {
				return
			}
			if let isDir = isDirectoryValue as? NSNumber {
				if isDir.boolValue {
					size += self.folderSize(url: (url as URL)).uint64Value
					return
				}
			}
			
			var isRegularFileValue : AnyObject?
			do {
				try url.getResourceValue(&isRegularFileValue, forKey: URLResourceKey.isRegularFileKey)
			} catch _ {
				return
			}
			if let isRegular = isRegularFileValue as? NSNumber {
				if !isRegular.boolValue {
					return
				}
			}
			
			var fileSizeValue : AnyObject?
			do {
				try url.getResourceValue(&fileSizeValue, forKey: URLResourceKey.fileAllocatedSizeKey)
			} catch _ {
				return
			}
			if fileSizeValue == nil {
				do {
					try url.getResourceValue(&fileSizeValue, forKey: URLResourceKey.totalFileAllocatedSizeKey)
				} catch _ {
					return
				}
			}
			if let fileSize = fileSizeValue as? NSNumber {
				size += fileSize.uint64Value
			}
		})
		return NSNumber(value: size)
	}
}
