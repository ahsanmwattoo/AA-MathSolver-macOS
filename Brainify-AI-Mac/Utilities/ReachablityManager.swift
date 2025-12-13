//
//  ReachablityManager.swift
//  DownTik
//
//  Created by Macbook Pro on 03/12/2024.
//

import Foundation

class ReachabilityManager {

  static let shared: ReachabilityManager = ReachabilityManager()

  // MARK: - Properties
  var reachability: Reachability?
  var netConnected: Bool = false
   
  // MARK: - Reachability
  func checkInternet() {
    do {
      reachability = try Reachability()
    } catch {
      print("Unable to create Reachability")
    }
    reachability?.whenReachable = { [weak self] reachability in
      guard let self else { return }
      self.netConnected = true
      NotificationCenter.default.post(name: .InternetConnectionChangeNotification, object: nil)
    }
    reachability?.whenUnreachable = { [weak self] _ in
      guard let self else { return }
      self.netConnected = false
      NotificationCenter.default.post(name: .InternetConnectionChangeNotification, object: nil)
      print("Not reachable")
    }
    do {
      try reachability?.startNotifier()
    } catch {
      print("Unable to start notifier")
    }
  }
}

extension Notification.Name {
  static let InternetConnectionChangeNotification = Notification.Name("LCLLanguageChangeNotification")
}










