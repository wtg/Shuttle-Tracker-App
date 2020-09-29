//
//  Stop.swift
//  Rensselaer Shuttle
//
//  Created by Gabriel Jacoby-Cooper on 9/21/20.
//

import MapKit

class Stop: NSObject, Identifiable {
	
	let id: Int
	let coordinate: CLLocationCoordinate2D
	let name: String
	
	init(id: Int, coordinate: CLLocationCoordinate2D, name: String) {
		self.id = id
		self.coordinate = coordinate
		self.name = name
	}
	
}

extension Stop: CustomAnnotation {
	
	var annotationView: MKAnnotationView {
		get {
			let pinAnnotationView = MKPinAnnotationView(annotation: self, reuseIdentifier: nil)
			pinAnnotationView.canShowCallout = true
			pinAnnotationView.pinTintColor = MKPinAnnotationView.purplePinColor()
			return pinAnnotationView
		}
	}
	
}

extension Stop: MKAnnotation {
	
	var title: String? {
		get {
			return self.name
		}
	}
	
}

extension Array where Element == Stop {
	
	static func download(_ stopsCallback: @escaping (_ stops: Self) -> Void) {
		let url = URL(string: "https://shuttles.rpi.edu/stops")!
		let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
			if let data = data {
				var stops = self.init()
				try! (JSONSerialization.jsonObject(with: data) as! [[String: Any]]).forEach { (rawStop) in
					guard let id = rawStop["id"] as? Int, let name = rawStop["name"] as? String, let latitude = rawStop["latitude"] as? Double, let longitude = rawStop["longitude"] as? Double else {
						return
					}
					let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
					stops.append(Stop(id: id, coordinate: coordinate, name: name))
				}
				stopsCallback(stops)
			}
		}
		task.resume()
	}
	
}
