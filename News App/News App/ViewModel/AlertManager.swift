//
//  AlertManager.swift
//  News App
//
//  Created by Karthick M on 06/11/23.
//

import Foundation
import UIKit

class AlertManager {
    
    static let shared = AlertManager()
    
    func AlertManger(message: String, controller: UIViewController) {
        
        let alertController = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        controller.present(alertController, animated: true)
        
    }
    
}
