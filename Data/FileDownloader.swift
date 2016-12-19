//
//  FileDownloader.swift
//  Commons
//
//  Created by Игорь Савельев on 19/12/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

import UIKit

enum FileDownloaderError : Error {
	case fromURLIsEmpty
	case destionationURLIsEmpty
}

class FileDownloader: NSObject, URLSessionDownloadDelegate {
	public static let sharedDownloader = FileDownloader()
	
	internal var successBlocks = [URL : [() -> Void]]()
	internal var failureBlocks = [URL : [(Error) -> Void]]()
	internal var progressBlocks = [URL : [(Int64, Int64) -> Void]]()
	internal var destinationURLs = [URL : [URL]]()
	internal var downloadingURLs = Set<URL>()
	
	internal let sessionQueue = OperationQueue()
	lazy internal var session : URLSession = { [unowned self] in
		return URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: self.sessionQueue)
	}()
	
	override init() {
		super.init()
		self.sessionQueue.name = String(describing: type (of: self))
	}
	
	public func downloadFile(fromURL: URL!, destinationURL: URL!, progress: ((Int64, Int64) -> Void)?, success: (() -> Void)?, failure: ((Error) -> Void)?) throws {
		if fromURL.absoluteString.characters.count == 0 {
			throw FileDownloaderError.fromURLIsEmpty
		}
		if destinationURL.path.characters.count == 0 {
			throw FileDownloaderError.destionationURLIsEmpty
		}
		
		var shouldDownload = false
		
		objc_sync_enter(self)
		if !self.downloadingURLs.contains(fromURL) {
			self.downloadingURLs.insert(fromURL)
			if self.successBlocks[fromURL] == nil {
				self.successBlocks[fromURL] = [() -> Void]()
			}
			if self.failureBlocks[fromURL] == nil {
				self.failureBlocks[fromURL] = [(Error) -> Void]()
			}
			if self.progressBlocks[fromURL] == nil {
				self.progressBlocks[fromURL] = [(Int64, Int64) -> Void]()
			}
			if self.destinationURLs[fromURL] == nil {
				self.destinationURLs[fromURL] = [URL]()
			}
			shouldDownload = true
		}
		if var sbs = self.successBlocks[fromURL], let sb = success {
			sbs.append(sb)
			self.successBlocks[fromURL] = sbs
		}
		if var fbs = self.failureBlocks[fromURL], let fb = failure {
			fbs.append(fb)
			self.failureBlocks[fromURL] = fbs
		}
		if var pbs = self.progressBlocks[fromURL], let pb = progress {
			pbs.append(pb)
			self.progressBlocks[fromURL] = pbs
		}
		if var dstns = self.destinationURLs[fromURL] {
			dstns.append(destinationURL)
			self.destinationURLs[fromURL] = dstns
		}
		objc_sync_exit(self)
		
		if shouldDownload {
			self.session.downloadTask(with: fromURL).resume()
		}
	}
	
	public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		guard let url = downloadTask.originalRequest?.url else {
			return
		}
		
		var sbs: [() -> Void]?
		var fbs: [(Error) -> Void]?
		var durls: [URL]?
		
		objc_sync_enter(self)
		sbs = self.successBlocks[url]
		fbs = self.failureBlocks[url]
		durls = self.destinationURLs[url]
		
		self.successBlocks.removeValue(forKey: url)
		self.failureBlocks.removeValue(forKey: url)
		self.progressBlocks.removeValue(forKey: url)
		self.destinationURLs.removeValue(forKey: url)
		self.downloadingURLs.remove(url)
		objc_sync_exit(self)
		
		if let error = downloadTask.error {
			if let blocks = fbs {
				for block in blocks {
					block(error)
				}
			}
		} else {
			if let urls = durls {
				var err: Error? = nil
				for url in urls {
					if FileManager.default.fileExists(atPath: url.path) {
						try? FileManager.default.removeItem(at: url)
					}
					do {
						try FileManager.default.copyItem(at: location, to: url)
					} catch {
						err = error
					}
				}
				try? FileManager.default.removeItem(at: location)
				
				if let e = err {
					if let blocks = fbs {
						for block in blocks {
							block(e)
						}
					}
				} else {
					if let blocks = sbs {
						for block in blocks {
							block()
						}
					}
				}
			}
		}
	}
	
	public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		guard let url = downloadTask.originalRequest?.url else {
			return
		}
		var pbs: [(Int64, Int64) -> Void]?
		objc_sync_enter(self)
		pbs = self.progressBlocks[url]
		objc_sync_exit(self)
		
		if let blocks = pbs {
			for block in blocks {
				block(totalBytesWritten, totalBytesExpectedToWrite)
			}
		}
	}
	
	public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		guard let url = task.originalRequest?.url else {
			return
		}
		
		var fbs: [(Error) -> Void]?

		objc_sync_enter(self)
		fbs = self.failureBlocks[url]
		self.successBlocks.removeValue(forKey: url)
		self.failureBlocks.removeValue(forKey: url)
		self.progressBlocks.removeValue(forKey: url)
		self.destinationURLs.removeValue(forKey: url)
		self.downloadingURLs.remove(url)
		objc_sync_exit(self)
		
		if let error = task.error, let blocks = fbs {
			for block in blocks {
				block(error)
			}
		}
	}

}
