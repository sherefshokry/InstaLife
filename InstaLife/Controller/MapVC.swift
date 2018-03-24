//
// MapVC.swift
//  InstaLife
//
//  Created by SherifShokry on 3/17/18.
//  Copyright © 2018 SherifShokry. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Alamofire
import AlamofireImage
import SwiftyJSON


class MapVC: UIViewController   {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imagesView: UIView!
    @IBOutlet weak var heightConstrain: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var downloadLabel: UILabel!
    
    
    let API_KEY = "23c53c1223e617a3eb75633e059de895"
    let URL = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
    
    let locationManager = CLLocationManager()
    var annotation : MKAnnotation?
   
    var photosArray : [Photo] = []
    var photosURL : [String] = []
    var cellNeedUpdate : Bool = false

    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        configureLocationServices()
        centerMapOnUserLocation()
        doubleTap()
    }
    
    
    
    
    
    func doubleTap()
    {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
    doubleTap.numberOfTapsRequired = 2
    mapView.addGestureRecognizer(doubleTap)
    }
    
    
    
    func swipeDown()
    {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown(sender:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    
    
    @objc func swipeDown(sender : UISwipeGestureRecognizer)
    {
        downloadLabel.text = ""
        heightConstrain.constant = 1
        mapView.layoutIfNeeded()
    }
    
    
    
    
    @objc func dropPin(sender : UITapGestureRecognizer) {
    
       removePin()
       swipeDown()
        downloadLabel.text = ""
        let touchPoint =   sender.location(in: mapView)
       let coordinatePoint =  mapView.convert(touchPoint, toCoordinateFrom: mapView)
       
        
        annotation = DrobPin( coordinate: coordinatePoint , identifier: "drobpin" )
        mapView.addAnnotation(annotation!)
        
        
        let viewRegion = MKCoordinateRegionMakeWithDistance( coordinatePoint , 500, 500)
        mapView.setRegion(viewRegion, animated: true)
      
      
        heightConstrain.constant = 300
       mapView.layoutIfNeeded()
        
        
       
        let params : [String : String] =  ["api_key" : API_KEY , "lat" : String(coordinatePoint.latitude) , "lon" : String(coordinatePoint.longitude) , "radius" : "1" , "radius_units" : "mi" , "format" : "json" , "nojsoncallback" : "1"]
      requestApiJson(params)

    }

    
    
    
    
  func removePin()
    {
        if annotation != nil
        {
            mapView.removeAnnotation(annotation!)
        }
    }
    

    
    
    func requestApiJson(_ parameter : [String : String] )
    {
        Alamofire.request(URL, method: .get, parameters: parameter ).responseJSON
            {
            response in
            if response.result.isSuccess
               {
                let json = JSON(response.value!)
                self.parseJsonData(json)
                
               }
            
           }
    }
    
    
    
    func parseJsonData(_ json : JSON)
    {
        photosArray = []
        photosURL = []
        var numOfPhotos = 1
        
        if json["photos"]["perpage"].int! > 30
        {
          numOfPhotos = 30
        }
        else
        {
            numOfPhotos = json["photos"]["perpage"].int!
        }
       
        downloadLabel.text = "0/30 photos downloaded"
       
        for index in 0..<numOfPhotos
        {
            let photoId : String = json["photos"]["photo"][index]["id"].stringValue
            let serverId : String = json["photos"]["photo"][index]["server"].stringValue
            let farmNum : String = json["photos"]["photo"][index]["farm"].stringValue
            let secretNum : String = json["photos"]["photo"][index]["secret"].stringValue
        
          let  photo = Photo( id: photoId , server: serverId , farm: farmNum, secret: secretNum )
          
            // photo url
            let URL : String = "https://farm\(json["photos"]["photo"][index]["farm"].stringValue).staticflickr.com/\(json["photos"]["photo"][index]["server"].stringValue)/\(json["photos"]["photo"][index]["id"].stringValue)_\(json["photos"]["photo"][index]["secret"].stringValue)_h_d.jpg"
           
            
            photosURL.append(URL)
            photosArray.append(photo)
        }
      
        downloadImages()
    }
    
    
    func downloadImages()
    {
     cellNeedUpdate = true
        var count = 0
       
        for index in 0..<photosURL.count
        {
            
           Alamofire.request(photosURL[index]).responseImage {
                response in
                guard let image = response.result.value else { return }
            count = count + 1
            self.downloadLabel.text = "\(count)/30 photos downloaded"
            self.photosArray[index].addPhoto(photo: image)
            print(image)
           self.collectionView.reloadData()
           
            }
          
    }
       downloadLabel.text = ""
    }
    
    
    
    @IBAction func centerMapBtnPressed(_ sender: Any)
    {
        centerMapOnUserLocation()
    }

    
}

extension MapVC:  CLLocationManagerDelegate{
    
    func configureLocationServices() {
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
    }
}



extension MapVC: MKMapViewDelegate {
   
    func centerMapOnUserLocation(){
        //Zoom to user location
        guard let coordinate = locationManager.location?.coordinate else { return }
        let viewRegion = MKCoordinateRegionMakeWithDistance( coordinate , 500, 500)
        mapView.setRegion(viewRegion, animated: true)
    }
    
}


extension MapVC: UICollectionViewDelegate , UICollectionViewDataSource ,  UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 30
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath as IndexPath) as! ImagesCollectionViewCell
        if(cellNeedUpdate){
            cell.img.image = photosArray[indexPath.row].photo
            
            //cell.backgroundColor = UIColor.black
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let popVC = storyboard?.instantiateViewController(withIdentifier :"secondViewController") as! ImageVC
        guard let photo = photosArray[indexPath.row].photo else { return }
        popVC.photo = photo
        present(popVC, animated: true, completion: nil)
    }
    
}
