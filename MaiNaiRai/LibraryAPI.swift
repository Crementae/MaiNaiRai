//
//  LibraryAPI.swift
//  MaiNaiRai
//
//  Created by Adisorn Chatnaratanakun on 12/2/2559 BE.
//  Copyright © 2559 Adisorn Chatnaratanakun. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import PromiseKit

class LibraryAPI: NSObject {
    
    static let sharedInstance = LibraryAPI()
    private let apiServer: APIServer
    private let httpClient: HTTPClient
    
    override init() {
        
        apiServer = APIServer()
        httpClient = HTTPClient()
        super.init()
        
    }
    
    func fetchSeasonDataFromServer(url: String) -> Promise<[Season]?> {
        return apiServer.getSeasonData(url: url)
    }
    
    func downloadImage(imageURL: NSURL) -> Promise<(UIImage)> {
        
        let (promise, fulfill, reject) = Promise<(UIImage)>.pending()
        
        httpClient.downloadImage(imageURL: imageURL).then { image in
            fulfill((image))
            }.catch { (error) -> Void in
                
                reject(error)
        }
        
        return promise
    }
}

