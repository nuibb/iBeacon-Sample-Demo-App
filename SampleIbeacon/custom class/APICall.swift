
import UIKit

class APICall: NSObject {
    
   
    func getDataFromJson1(url: String, parameter: String, completion: @escaping (_ success: [String : Any]) -> Void) {
        
        //@escaping...If a closure is passed as an argument to a function and it is invoked after the function returns, the closure is @escaping.
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let postString = parameter
        
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { Data, response, error in
        // print(response!)
            guard let data = Data, error == nil else {  // check for fundamental networking error
                
                print("error=\(String(describing: error))")
                
                return
            }
            print(data)
           
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {  // check for http errors

                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print(response!)

                return

            }
 
        }
        task.resume()
    }
    
   /*
    func getDataFromJson2(url: String, parameter: String, completion: @escaping (_ success: [String : Any]) -> Void) {
        
        //@escaping...If a closure is passed as an argument to a function and it is invoked after the function returns, the closure is @escaping.
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let postString = parameter
        
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { Data, response, error in
            
            guard let data = Data, error == nil else {  // check for fundamental networking error
                
         //       print("error=\(error)")
                
                return
            }
            
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {  // check for http errors
                
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print(response!)
                
                return
                
            }
            
            let responseString  = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
            print("fdgerg\(responseString)")
            completion(responseString)
            
        }
        task.resume()
    }
    
    
    
    func getDataFromJson3(url: String, parameter: String, completion: @escaping (_ success: [String : Any]) -> Void) {
        
        //@escaping...If a closure is passed as an argument to a function and it is invoked after the function returns, the closure is @escaping.
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        let postString = parameter
        
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { Data, response, error in
            
            guard let data = Data, error == nil else {  // check for fundamental networking error
                
                //print("error=\(error)")
                
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {  // check for http errors
                
                // print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print(response!)
                
                return
                
            }
            
            let responseString  = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
            print("fdgerg\(responseString)")
            completion(responseString)
            
        }
        task.resume()
    }
    
    */
    
}
