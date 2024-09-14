//
//  ViewController.swift
//  drawLine(GoogleMaps)
//
//  Created by Macbook on 14/09/2024.
//

import UIKit
import GoogleMaps
import GooglePlaces
class ViewController: UIViewController {

    var searchBar: UISearchBar!

    let locationManger = CLLocationManager()
    @IBOutlet weak var mapView: GMSMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled(){
            checkAuth()
        }else{
            locationManger.requestWhenInUseAuthorization()
        }
        
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 50, width: self.view.frame.width, height: 50))
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.backgroundColor = .white
        searchBar.placeholder = "Search for places"
        searchBar.delegate = self
        self.view.addSubview(searchBar)

        
        
    }
    
    func  checkAuth(){
        switch locationManger.authorizationStatus{
        case .notDetermined:
            locationManger.requestLocation()
            break
        case .authorizedAlways:
            locationManger.startUpdatingLocation()
            break
        case .authorizedWhenInUse:
            locationManger.startUpdatingLocation()

            break

        case .restricted:

            break
        case .denied:
            break
        default:
            break
        }
    }
    
    func ZoomToLocation(location : CLLocationCoordinate2D){
        let camera = GMSCameraPosition(latitude: location.latitude, longitude: location.longitude, zoom: 10)
        mapView.camera = camera
    }
    func  setMarker(postion : CLLocationCoordinate2D , title : String?){
        let marker = GMSMarker(position: postion)
        marker.title = title
        marker.map = mapView
    }
    
    func drawLine(source : CLLocationCoordinate2D , destination : CLLocationCoordinate2D){
        let path = GMSMutablePath()
        path.add(source)
        path.add(destination)
        // create polyline
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = .blue
        polyline.strokeWidth = 5.0
        polyline.map = mapView
        
    }
    
}



extension ViewController : UISearchBarDelegate{
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let autoCompetedConstroller = GMSAutocompleteViewController()
        autoCompetedConstroller.delegate = self
        present(autoCompetedConstroller, animated: true)
    }
    
}




extension ViewController : GMSAutocompleteViewControllerDelegate{
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true)
        print("Place name: \(place.name ?? "")")
        print("Place address: \(place.formattedAddress ?? "")")
        let locationCoordinate = place.coordinate
       setMarker(postion: locationCoordinate, title: "Destination")
        drawLine(source: locationManger.location!.coordinate, destination: locationCoordinate)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error" , error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true)
        print("Autocomplete cancelled.")
    }
    
    
}


extension ViewController : CLLocationManagerDelegate{
 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            ZoomToLocation(location: location.coordinate)
            setMarker(postion: location.coordinate, title: "Source")
        }
        locationManger.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{
        case .notDetermined:
            locationManger.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse :
            locationManger.startUpdatingLocation()
            break
        case .authorizedAlways:
            locationManger.startUpdatingLocation()
            break
        case .denied:
            break
        case .restricted:
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}
