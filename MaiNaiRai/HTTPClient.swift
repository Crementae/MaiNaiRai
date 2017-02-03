//
//  HTTPClient.swift
//  MaiNaiRai
//
//  Created by Adisorn Chatnaratanakun on 12/2/2559 BE.
//  Copyright © 2559 Adisorn Chatnaratanakun. All rights reserved.
//
import UIKit
import Alamofire
import ObjectMapper
import PromiseKit
import SDWebImage

enum HTTPClientError: Error, CustomStringConvertible {
    case ResponseError(StatusCode:Int)
    case CannotDownloadImage
    case CannotConnectToServer(errorMessage: String)
    case Unknown
    
    var description: String {
        switch self {
        case .ResponseError(let httpStatusCode ):
            return "HTTP response error with HTTP code: \(httpStatusCode)"
        case .CannotDownloadImage:
            return "Can not download image."
        case .CannotConnectToServer(let errorMessage):
            return errorMessage
        default:
            return "Unknown Error"
        }
    }
}

class HTTPClient {
    
    func get(url: String) -> DataRequest{
        return Alamofire.request(url, method: .get)
    }
    
    func downloadImage(imageURL: NSURL) -> Promise<(UIImage)> {
        
        let (promise, fulfill, reject) = Promise<(UIImage)>.pending()
        
        let downloader = SDWebImageDownloader.shared()
        
        downloader!.downloadImage(with: imageURL as URL!, options: .useNSURLCache, progress: nil, completed: {
            (image, data, error, finished) -> Void in
            
            if finished {
                fulfill(image!)
            }else{
                reject(HTTPClientError.CannotDownloadImage)
            }
        })
        
        return promise
    }

    
}

