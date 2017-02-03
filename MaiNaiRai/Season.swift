//
//  Season.swift
//  MaiNaiRai
//
//  Created by Adisorn Chatnaratanakun on 11/21/2559 BE.
//  Copyright © 2559 Adisorn Chatnaratanakun. All rights reserved.
//

import Foundation
import ObjectMapper

class Season: Mappable{
    var tree_id: String?
    var name: String?
    var local_name: String?
    var detail: String?
    var benefit: String?
    var locations: [Coordinate]?
    var scientific_name: String?
    var family_name: String?
    var thumbnail: String?
    var gallery: [String]?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        tree_id         <- map["tree_id"]
        name            <- map["name"]
        local_name      <- map["local_name"]
        detail          <- map["detail"]
        benefit         <- map["benefit"]
        locations       <- map["locations"]
        scientific_name <- map["scientific_name"]
        family_name     <- map["family_name"]
        thumbnail       <- map["thumbnail"]
        gallery         <- map["gallery"]
        
    }
    
    class Coordinate: Mappable {
        
        var lat: String?
        var lng: String?
        
        required convenience init?(map: Map) {
            self.init()
        }
        
        func mapping(map: Map) {
            
            lat <- map["lat"]
            lng <- map["lng"]
        }
        
    }
}
