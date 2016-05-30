//
//  SearchService.swift
//  Catchit
//
//  Created by viktor johansson on 20/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import Foundation
import Alamofire

// MARK: Protocols
protocol SearchServiceDelegate {
    func setSearchResult(json: AnyObject)
}

class SearchService {
    
    // MARK: Setup
    var delegate: SearchServiceDelegate?
    let headers = NSUserDefaults.standardUserDefaults().objectForKey("headers") as? [String : String]
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String

    // MARK: GET-Requests
    func search(searchString: String) {
        let newSearchString = searchString.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        Alamofire.request(.GET, url + "search_results/autocomplete_search_result_record_string?term=" + newSearchString!, headers: headers)
            .responseJSON { response in
                print("1")
                if let JSON = response.result.value {
                    print("2")
                    if self.delegate != nil {
                        print("3")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            print("4")
                            self.delegate?.setSearchResult(JSON)
                        })
                    }
                }
                
        }
    }    
}
