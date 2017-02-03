//
//  Alamofile+ObjectMapper.swift
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

extension DataRequest {
    public func responseArray<T: Mappable>() -> Promise<[T]?> {
        
        let (promise, fullfil, reject) = Promise<[T]?>.pending()
        
        
        responseArray {
            (response: DataResponse<[T]>) in
            
            switch response.result {
                
            case .success(let value):
                fullfil(value)
                
            case .failure(let error):
                
                guard let res = response.response else {
                    reject(error)
                    return
                }
                reject(HTTPClientError.ResponseError(StatusCode: res.statusCode))
            }
        }
        return promise
    }
}
