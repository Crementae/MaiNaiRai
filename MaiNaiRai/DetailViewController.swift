//
//  DetailViewController.swift
//  MaiNaiRai
//
//  Created by Adisorn Chatnaratanakun on 12/3/2559 BE.
//  Copyright © 2559 Adisorn Chatnaratanakun. All rights reserved.
//

import UIKit
import moa
import Auk
import GoogleMaps
import CoreLocation
import HDAugmentedReality

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GMSMapViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var mapView: GMSMapView!
    
    var seasonData: Season?
    var markerArray = Season.Coordinate()
    var firstCoordinate = Season.Coordinate()
    var thumbnailImage: UIImage?
    fileprivate let locationManager = CLLocationManager()
    fileprivate var arViewController: ARViewController!
    fileprivate var places = [Place]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        for treeGallery in (seasonData?.gallery!)! {
            scrollView.auk.show(url: treeGallery)
        }
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorColor = UIColor.lightGray
        loadGoogleMapsAndAddPlaceToAR()
        configureLocationManager()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "AR", style: .plain, target: self, action: #selector(showAR))
      
    }
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
    }
    
    func loadGoogleMapsAndAddPlaceToAR(){
   
        mapView.delegate = self
        
        guard (seasonData?.locations?.count)! >= 1 else{
            return print("Tree location is nil")
        }
        
        
        let firstLat = seasonData?.locations?[0].lat
        let firstLng = seasonData?.locations?[0].lng
        
        let cameraPosition = GMSCameraPosition.camera(withLatitude: (firstLat?.toDouble())!
            , longitude: (firstLng?.toDouble())!, zoom: 16.0)
        
        mapView.camera = cameraPosition

        
        for marker in (seasonData?.locations)! {
            createMarker(lat: Double(marker.lat!)!, lng: Double(marker.lng!)!)
            
            let location = CLLocation.init(latitude: Double(marker.lat!)!, longitude: Double(marker.lng!)!)
            //let location = CLLocation.init(latitude: 13.7426, longitude: 100.5488)
            var imageThumbnail = UIImage()
            
            guard let plantName = seasonData?.name, let thumbnailURLString = seasonData?.thumbnail else{
                print("no data")
                return
            }
            
            let url = NSURL.init(string: thumbnailURLString)
            
            //Download thumbnail and add the data to place object.
            LibraryAPI.sharedInstance.downloadImage(imageURL: url!).then(execute: { (image: UIImage) -> () in
                imageThumbnail = image
                let place = Place.init(location: location, name: plantName, thumbnail: imageThumbnail)
                self.places.append(place)
                print("place: \(place)")
            }).catch(execute: { (error) in
                print(error)
            })
            
        }
        

    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        let customInfoWindow = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?.first as! CustomInfoWindow
        customInfoWindow.name.text = marker.title
        customInfoWindow.localName.text = marker.snippet
        customInfoWindow.thumbnail.image = thumbnailImage
        
        return customInfoWindow
    }
    
    func createMarker(lat: Double, lng: Double) {
        
        print("Create: \(lat)")

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        marker.title = seasonData?.name
        marker.snippet = seasonData?.local_name
        marker.map = mapView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DetailTableViewCell
        
        
        
        switch indexPath.row {
        case 0: cell.fieldLabel.text = "Name:"
                cell.valueLabel.text = seasonData?.name
        case 1: cell.fieldLabel.text = "Scientific name:"
                cell.valueLabel.text = seasonData?.scientific_name
        case 2: cell.fieldLabel.text = "Family name:"
                cell.valueLabel.text = seasonData?.family_name
        case 3: cell.fieldLabel.text = "Local name:"
                if seasonData?.local_name == "" {
                    cell.valueLabel.text = "Dosen't have local name"
                }else{
                    cell.valueLabel.text = seasonData?.local_name
                }
        case 4: cell.fieldLabel.text = "Detail"
                cell.valueLabel.text = seasonData?.detail
        case 5: cell.fieldLabel.text = "Benefit"
                cell.valueLabel.text = seasonData?.benefit
        default:
            break
        }
        
        return cell
    }
    
    func showAR(_ sender: Any) {
        arViewController = ARViewController()
        arViewController.dataSource = self
        arViewController.maxVisibleAnnotations = 30
        arViewController.headingSmoothingFactor = 0.05
        arViewController.setAnnotations(places)
        
        
        self.present(arViewController, animated: true, completion: nil)
        
    }
}

extension DetailViewController: ARDataSource {
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = AnnotationView()
        annotationView.annotation = viewForAnnotation
        annotationView.delegate = self
        annotationView.frame = CGRect.init(x: 0, y: 0, width: 150, height: 65)
        
        return annotationView
    }
}

extension DetailViewController: AnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView) {
        print("Tapped view for POI")
    }
}

extension DetailViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.startUpdatingLocation()
    }
}

extension String {
    func toDouble() -> Double? {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US_POSIX")
        return numberFormatter.number(from: self)?.doubleValue
    }
}
