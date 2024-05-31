//
//  NetworkManager.swift
//  News App
//
//  Created by Karthick M on 07/11/23.
//

import Foundation
import Reachability

class NetworkManager {
    
    static let shared = NetworkManager()
    let reachability = try! Reachability()
    
    //MARK: - NETWORK MONITOR
    
    func startMonitoring(controller: UIViewController) {
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("reachable")
                controller.view.window?.rootViewController?.dismiss(animated: true)
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            if let reachabilityError = controller.storyboard?.instantiateViewController(identifier: "ReachabilityErrorViewController") as? ReachabilityErrorViewController {
                 controller.present(reachabilityError, animated: true)
            }
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
    }
    
    deinit {
        reachability.stopNotifier()
    }
    
}

