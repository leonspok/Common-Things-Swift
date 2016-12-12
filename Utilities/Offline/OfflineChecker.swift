//
//  OfflineChecker.swift
//  Commons
//
//  Created by Игорь Савельев on 12/12/2016.
//  Copyright © 2016 Leonspok. All rights reserved.
//

import UIKit

let kOfflineStatusChangedNotification = "kOfflineStatusChangedNotification";

enum NetworkConnection : String {
	case wifi = "wifi"
	case cellular = "cellular"
	case none = "none"
}

class OfflineChecker : NSObject {
	static let defaultChecker = OfflineChecker()
	
	internal let reachability = Reachability.forInternetConnection()
	private(set) var offline : Bool = false
	private(set) var networkConnection = NetworkConnection.cellular
	let notificationCenter = NotificationCenter()
	
	internal var _enabled : Bool = false;
	var enabled: Bool {
		set {
			_enabled = newValue
			if _enabled {
				self.reachability?.startNotifier()
			} else {
				self.reachability?.stopNotifier()
			}
		}
		get {
			return _enabled
		}
	}
	
	override init() {
		super.init()
		NotificationCenter.default.addObserver(self, selector: #selector(OfflineChecker.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
		self.enabled = true
		self.reachabilityChanged()
		DispatchQueue.main.async {
			Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(OfflineChecker.reachabilityChanged), userInfo: nil, repeats: true)
		}
	}
	
	internal func reachabilityChanged() {
		var newConnection = NetworkConnection.wifi
		let status = self.reachability?.currentReachabilityStatus()
		if status == .NotReachable {
			newConnection = .none
		} else if status == .ReachableViaWiFi {
			newConnection = .wifi
		} else {
			newConnection = .cellular
		}
		
		var connection = self.networkConnection
		if newConnection != self.networkConnection {
			connection = newConnection
		}
		
		switch connection {
		case .none:
			self.offline = true
		case .cellular, .wifi:
			self.offline = false
		}
		
		if newConnection != self.networkConnection {
			self.networkConnection = newConnection
			DispatchQueue.main.async {
				self.notificationCenter.post(name: NSNotification.Name(rawValue: kOfflineStatusChangedNotification), object: nil)
			}
		}
	}
}
