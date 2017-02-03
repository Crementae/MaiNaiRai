//
//  AnnotationView.swift
//  MaiNaiRai
//
//  Created by Adisorn Chatnaratanakun on 2/3/2560 BE.
//  Copyright © 2560 Adisorn Chatnaratanakun. All rights reserved.
//

import Foundation
import UIKit
import HDAugmentedReality

protocol AnnotationViewDelegate{
    func didTouch(annotationView: AnnotationView)
}

class AnnotationView: ARAnnotationView {
    
    var titleLabel: UILabel?
    var distanceLabel: UILabel?
    var thumbnail: UIImageView?
    var delegate: AnnotationViewDelegate?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        loadUI()
    }
    
    func loadUI(){
        
        titleLabel?.removeFromSuperview()
        distanceLabel?.removeFromSuperview()
        thumbnail?.removeFromSuperview()
        
        let label = UILabel.init(frame: CGRect.init(x: 70, y: 0, width: self.frame.size.width, height: 40))
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.backgroundColor = UIColor.init(white: 0.3, alpha: 0.7)
        label.textColor = UIColor.white
        self.addSubview(label)
        self.titleLabel = label
        
        
        distanceLabel = UILabel.init(frame: CGRect.init(x: 70, y: 40, width: self.frame.size.width, height: 25))
        distanceLabel?.font = UIFont.systemFont(ofSize: 12)
        distanceLabel?.backgroundColor = UIColor.init(white: 0.3, alpha: 0.7)
        distanceLabel?.textColor = UIColor.green
        self.addSubview(distanceLabel!)
        
        
        thumbnail = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 50))
        self.addSubview(thumbnail!)
        
        if let annotation = annotation as? Place {
            self.titleLabel?.text = annotation.name
            self.distanceLabel?.text = String(format: "%.2f km", annotation.distanceFromUser / 1000)
            self.thumbnail?.image = annotation.thumbnail
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.frame = CGRect.init(x: 70, y: 0, width: self.frame.size.width, height: 40)
        distanceLabel?.frame = CGRect.init(x: 70, y: 40, width: self.frame.size.width, height: 25)
        thumbnail?.frame = CGRect.init(x: 0, y: 0, width: 70, height: 65)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didTouch(annotationView: self)
    }
    
}
