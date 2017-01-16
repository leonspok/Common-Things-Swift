//
//  ImageDownloadManager.swift
//  Commons
//
//  Created by Игорь Савельев on 16/01/2017.
//  Copyright © 2017 Leonspok. All rights reserved.
//

import UIKit

class ImageDownloadManager: NSObject {
	public enum ImageOptions {
		case original
		case resized(width: CGFloat, height: CGFloat)
		case rounded(width: CGFloat)
		
		public static func squareImage(size: CGFloat) -> ImageOptions {
			return .resized(width: size, height: size)
		}
	}
	
	public static let defaultManager = ImageDownloadManager();
	
	lazy public var pathToCacheFolder : String! = { [unowned self] in
		let cachesFolder = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
		return cachesFolder! + "/Images"
	}()
	
	public func hasImage(fromURL: URL!, options: ImageOptions) -> Bool {
		guard let fileName = self.generateNameForImage(fromURL: fromURL, options: options) else {
			return false
		}
		let path = self.pathToCacheFolder+"/"+fileName
		return FileManager.default.fileExists(atPath: path)
	}
	
	public func fetchImage(fromURL: URL!, options: ImageOptions) -> UIImage? {
		guard let fileName = self.generateNameForImage(fromURL: fromURL, options: options) else {
			return nil
		}
		let path = self.pathToCacheFolder+"/"+fileName
		if FileManager.default.fileExists(atPath: path) {
			if let image = imagesCache.object(forKey: fileName as NSString) {
				return image
			} else {
				let image = UIImage.init(contentsOfFile: path)
				if let im = image {
					self.imagesCache.setObject(im, forKey: fileName as NSString)
				} else {
					try? FileManager.default.removeItem(atPath: path)
				}
				return image
			}
		} else {
			return nil
		}
	}
	
	public func downloadImage(fromURL: URL!, options: ImageOptions, completion: ((UIImage?) -> Void)?) -> Void {
		DispatchQueue.global(qos: .userInitiated).async {
			guard let fileName = self.generateNameForImage(fromURL: fromURL, options: options) else {
				DispatchQueue.main.async {
					if let c = completion {
						c(nil)
					}
				}
				return
			}
			let path = self.pathToCacheFolder+"/"+fileName
			
			if self.hasImage(fromURL: fromURL, options: .original) {
				let image = self.fetchImage(fromURL: fromURL, options: .original)
				let cost = 100
				
				if let im = image {
					switch options {
					case .original:
						self.imagesCache.setObject(im, forKey: fileName as NSString, cost: cost)
						DispatchQueue.main.async {
							if let c = completion {
								c(im)
							}
						}
					case .resized(width: _, height: _), .rounded(width: _):
						self.renderingQueue.addOperation { [unowned self] in
							let renderingResult = self.process(image: im, options: options)
							self.imagesCache.setObject(renderingResult.resultImage, forKey: fileName as NSString, cost: renderingResult.cost)
							DispatchQueue.main.async {
								if let c = completion {
									c(renderingResult.resultImage)
								}
							}
						}
					}
					return
				}
			}
			
			let originalFileName = self.generateNameForImage(fromURL: fromURL, options: .original)!
			let originalFilePath = self.pathToCacheFolder+"/"+originalFileName
			
			try? FileDownloader.sharedDownloader.downloadFile(fromURL: fromURL, destinationURL: URL.init(fileURLWithPath: originalFilePath), progress: nil, success: {
				DispatchQueue.global(qos: .userInitiated).async {
					let originalImage = UIImage.init(contentsOfFile: originalFilePath)
					if let original = originalImage {
						switch options {
						case .original:
							self.imagesCache.setObject(original, forKey: fileName as NSString, cost: 100)
							DispatchQueue.main.async {
								if let c = completion {
									c(original)
								}
							}
						case .resized(width: _, height: _), .rounded(width: _):
							self.renderingQueue.addOperation { [unowned self] in
								let renderingResult = self.process(image: original, options: options)
								if let imageData = UIImagePNGRepresentation(renderingResult.resultImage) {
									try? imageData.write(to: URL.init(fileURLWithPath: path), options: .atomicWrite)
								}
								self.imagesCache.setObject(renderingResult.resultImage, forKey: fileName as NSString, cost: renderingResult.cost)
								DispatchQueue.main.async {
									if let c = completion {
										c(renderingResult.resultImage)
									}
								}
							}
						}
					} else {
						DispatchQueue.main.async {
							if let c = completion {
								c(nil)
							}
						}
					}
				}
			}, failure: { (error: Error) in
				DispatchQueue.main.async {
					if let c = completion {
						c(nil)
					}
				}
			})
		}
	}
	
	override init() {
		super.init()
		self.createFolderIfNeeded()
	}
	
	lazy internal var imagesCache : NSCache<NSString, UIImage>! = { [unowned self] in
		let cache = NSCache<NSString, UIImage>()
		cache.name = "images"
		cache.totalCostLimit = 400
		cache.countLimit = 50
		return cache
	}()
	
	lazy internal var renderingQueue : OperationQueue! = { [unowned self] in
		let operationQueue = OperationQueue()
		operationQueue.name = "rendering queue"
		return operationQueue
	}()
	
	internal func createFolderIfNeeded() -> Void {
		if !FileManager.default.fileExists(atPath: self.pathToCacheFolder) {
			do {
				try FileManager.default.createDirectory(atPath: self.pathToCacheFolder, withIntermediateDirectories: true, attributes: nil)
			} catch _ {
				return
			}
		}
	}
	
	internal func generateNameForImage(fromURL: URL, options: ImageOptions) -> String? {
		guard let hash = fromURL.absoluteString.md5() else {
			return nil
		}
		
		var postfix: String!
		switch options {
		case .original:
			postfix = ""
		case .resized(let width, let height):
			postfix = "_w\(Int(width))h\(Int(height))"
		case .rounded(let width):
			postfix = "_rounded_w\(Int(width))"
		}
		
		let name = String.init(format: "%@%@.png", hash, postfix)
		return name
	}
	
	internal func process(image source: UIImage!, options: ImageOptions) -> (resultImage: UIImage, cost: Int) {
		let renderedImage: UIImage!
		let cost: Int
		switch options {
		case .original:
			renderedImage = source
			cost = 100
		case .resized(let width, let height):
			renderedImage = source.scaledImage(size: CGSize.init(width: width, height: height))
			if min(width, height) <= 100 {
				cost = 1
			} else {
				cost = Int(sqrt(width/100))
			}
		case .rounded(let width):
			renderedImage = source.roundedImage(size: CGSize.init(width: width, height: width))
			if width <= 100 {
				cost = 1
			} else {
				cost = Int(sqrt(width/100))
			}
		}
		return (renderedImage, cost)
	}
	
	
}
