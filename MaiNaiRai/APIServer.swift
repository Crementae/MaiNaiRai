//
//  APIServer.swift
//  MaiNaiRai
//
//  Created by Adisorn Chatnaratanakun on 12/2/2559 BE.
//  Copyright © 2559 Adisorn Chatnaratanakun. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import PromiseKit

class APIServer: NSObject {
    private let httpClient: HTTPClient
    
    override init() {
        httpClient = HTTPClient()
    }
    
    func getSeasonData(url: String) -> Promise<[Season]?>{
        //url = "http://rmfl.nagasoftware.com/api/plant_by_season.php?lang_code=2&season_id=0"
        
        let (promise, fullfil, reject) = Promise<[Season]?>.pending()
        
        let promiseResponse: Promise<[Season]?> = httpClient.get(url: url).responseArray() as Promise<[Season]?>
        promiseResponse.then { (season: [Season]?) -> () in
            
            fullfil(season)
            print("season: \(season))")
            
            }.catch { (error) -> Void in
            
                if case HTTPClientError.ResponseError(let statusCode) = error {
                    if 200..<300 ~= statusCode { //return code = 200 when there is no data
                        fullfil([Season]())
                    }
                }
            
                reject(error)

        }
        return promise
    }
    
    
    
    
    
}
