//
//  APICall.swift
//  FileDownloader
//
//  Created by MobioApp on 9/12/17.
//  Copyright © 2017 MobioApp. All rights reserved.
//

import Foundation

import UIKit


class FileDownloader: NSObject {
    

    func downloadFileFromServer(url: String, parameter: String, completion: @escaping (_ success: URL) -> Void) {
        
        //   @escaping...If a closure is passed as an argument to a function and it is invoked after the function returns, the closure is @escaping.
        
        //Create URL to the source file you want to download
        
        let fileURL = URL(string: url)
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                    print("temporary url for the downloaded file is :\(tempLocalUrl)")
                    completion(tempLocalUrl)
                }
                
            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription as Any);
            }
        }
        task.resume()
        
    }
      
}





