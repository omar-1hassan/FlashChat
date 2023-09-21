//
//  LocationPickerVC.swift
//  FlashChat
//
//  Created by mac on 20/09/2023.
//

import UIKit
import CoreLocation
import MapKit

class LocationPickerVC: UIViewController {
    
    public var completion: ((CLLocationCoordinate2D) -> Void)?
    private var coordinates: CLLocationCoordinate2D?
    private var isPickaple = true
    private let map: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    init(coordinate: CLLocationCoordinate2D?) {
        self.coordinates = coordinate
        self.isPickaple = coordinates == nil
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        if isPickaple {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "send",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(sendButtonTapped))
            map.isUserInteractionEnabled = true
            
            let gesture = UITapGestureRecognizer(target: self,
                                                 action: #selector(didTapMap))
            gesture.numberOfTouchesRequired = 1
            gesture.numberOfTapsRequired = 1
            map.addGestureRecognizer(gesture)
        }
        else {
            //just showing location
            guard let  coordinates = self.coordinates else {
                return
            }
            
            //drop a pin on that location
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            map.addAnnotation(pin)
        }
        
        view.addSubview(map)
        
    }
    @objc func sendButtonTapped(){
        guard let coordinates = coordinates else {
            return
        }
        navigationController?.popViewController(animated: true)
        completion?(coordinates)
    }
    
    @objc func didTapMap(_ gesture: UITapGestureRecognizer){
        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.coordinates = coordinates
        
        //This for loop is to remove anu pin if the user taps on map again
        //only one pin in our map
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
        //drop pin in this location
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        map.addAnnotation(pin)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
    
}
