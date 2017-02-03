//
//  Place.swift
//  MaiNaiRai
//
//  Created by Adisorn Chatnaratanakun on 2/3/2560 BE.
//  Copyright © 2560 Adisorn Chatnaratanakun. All rights reserved.
//

import Foundation
import CoreLocation
import HDAugmentedReality

class Place: ARAnnotation {
    
    let name: String
    let thumbnail: UIImage
    
    init(location: CLLocation, name: String, thumbnail: UIImage) {
        self.name = name
        self.thumbnail = thumbnail
        super.init()
        self.location = location
    }
    
}
