//
//  HttpControl.swift
//  FinalProject
//
//  Created by Runex on 7/30/15.
//
//

import UIKit

protocol HttpProtocol {
    func didRecieveResults(results: NSDictionary)
    
}

class HttpControl: NSObject {
    
    var delegate : HttpProtocol?
    
    func onSearch(url : String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let nsUrl = NSURL(string: url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        let request:NSURLRequest = NSURLRequest(URL : nsUrl!)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let task = session.dataTaskWithRequest(request){
            (data,response,error) -> Void in
            if error == nil {
                if let jsonResult = (try? NSJSONSerialization.JSONObjectWithData(data,options:NSJSONReadingOptions.MutableContainers)) as? NSDictionary {
                    self.delegate?.didRecieveResults(jsonResult)
                }
                else {
                    if let responseData = data {
                        let responseString = NSString(data: responseData, encoding: NSUTF8StringEncoding)
                        print("Error creating json objects from response: \(responseString)")
                    }
                    else {
                        print("Error creating json objects from response")
                    }
                }
            }
            else {
                print(error)
            }
        }
        task.resume()
    }
}
