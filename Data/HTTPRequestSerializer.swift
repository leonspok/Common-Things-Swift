//
//  HTTPRequestSerializer.swift
//  Commons
//
//  Created by Игорь Савельев on 22/12/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

import UIKit

class HTTPRequestSerializer: NSObject {

	public enum RequestMethod : String {
		case get = "GET"
		case post = "POST"
		case put = "PUT"
		case delete = "DELETE"
	}
	
	public static let sharedSerializer = HTTPRequestSerializer()
	
	public var additionalHeaders: [String : String]?
	public var allowCellularAccess = true
	public var timeoutInterval = 60.0
	public var networkServiceType = NSURLRequest.NetworkServiceType.default
	public var cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
	
	public func buildURLEncodedRequest(withMethod method: RequestMethod, url: URL!, params: [String : AnyObject]?) -> URLRequest {
		var request = URLRequest.init(url: url, cachePolicy: self.cachePolicy, timeoutInterval: self.timeoutInterval)
		request.httpMethod = method.rawValue
		if let parameters = params {
			var queryString = String()
			var i = 0
			for (key, value) in parameters {
				let valueString: String
				switch value {
					case let val as String:
						valueString = val
					case let val as Decimal:
						valueString = "\(val)"
					case let val as Bool:
						if val {
							valueString = "true"
						} else {
							valueString = "false"
						}
					default:
						valueString = String(describing: value)
				}
				let k : String? = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryParameterValueAllowed)
				let v : String? = valueString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryParameterValueAllowed)
				if let key = k, let value = v {
					queryString += "\(key)=\(value)"
				}
				
				if i < parameters.count {
					queryString += "&"
				}
				i += 1
			}
			
			switch method {
			case .get:
				if let absoluteStr = request.url?.absoluteString {
					var urlString = absoluteStr
					if let _ = request.url?.query {
						urlString += "&\(queryString)"
					} else {
						urlString += queryString
					}
					request.url = URL.init(string: urlString)
				}
			case .post, .put, .delete:
				request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
				request.httpBody = queryString.data(using: .utf8)
			}
		}
		
		request.networkServiceType = self.networkServiceType
		request.allowsCellularAccess = self.allowCellularAccess
		if let headers = self.additionalHeaders {
			for (header, value) in headers {
				request.setValue(value, forHTTPHeaderField: header)
			}
		}
		
		return request
	}
	
	public func buildMultipartRequest(withMethod method: RequestMethod, url: URL!, params: [String : AnyObject]?) -> URLRequest {
		var request = URLRequest.init(url: url, cachePolicy: self.cachePolicy, timeoutInterval: self.timeoutInterval)
		request.httpMethod = method.rawValue
		
		let boundary = UUID().uuidString
		request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
		
		var body = Data()
		
		if let parameters = params {
			for (key, value) in parameters {
				guard let topLine = "\n==\(boundary)\n".data(using: .utf8) else {
					continue
				}
				body.append(topLine)
				
				switch value {
				case let val as Data:
					guard let disposition = "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key).bin\"\n".data(using: .utf8), let type = "Content-Type: application/octet-stream\n\n".data(using: .utf8) else {
						continue
					}
					body.append(disposition)
					body.append(type)
					body.append(val)
				case let val as UIImage:
					guard let disposition = "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key).jpg\"\n".data(using: .utf8), let type = "Content-Type: image/jpeg\n\n".data(using: .utf8) else {
						continue
					}
					body.append(disposition)
					body.append(type)
					guard let imageData = UIImageJPEGRepresentation(val, 0.8) else {
						continue
					}
					body.append(imageData)
				default:
					let valueString: String
					switch value {
						case let val as String:
							valueString = val
						case let val as Decimal:
							valueString = "\(val)"
						case let val as Bool:
							if val {
								valueString = "true"
							} else {
								valueString = "false"
							}
						default:
							valueString = String(describing: value)
					}
					guard let disposition = "Content-Disposition: form-data; name=\"\(key)\"\n\n".data(using: .utf8), let valueData = valueString.data(using: .utf8) else {
						continue
					}
					body.append(disposition)
					body.append(valueData)
				}
			}
		}
		if let bottomLine = "\n--\(boundary)--\n".data(using: .utf8) {
			body.append(bottomLine)
		}
		request.httpBody = body
		return request
	}
}
