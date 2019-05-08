//
//  AlertController.swift
//  DSLogin
//
//  Created by Steve JobsOne on 5/22/17.
//  Copyright © 2017 Steve JobsOne. All rights reserved.
//

import UIKit

class AlertController: NSObject {
    
    static let sharedInstance = AlertController()
    var alertController: UIAlertController!
    
    func getCustomAlertWithOkayButton(title: String, msg: String, handler: @escaping (()->Void)) -> UIAlertController {
        
        alertController = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)
        alertController.addAction(getCustomAlertAction(title: "OK", handler: handler))
        
        return alertController
        
    }
    
    private func getCustomAlertAction(title: String, handler: @escaping (()->Void)) -> UIAlertAction {
        let action = UIAlertAction.init(title: title,
                                        style: .default,
                                        handler: { action in
                                            handler()
        })
        return action
    }
    
}
