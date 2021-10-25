//
//  PrimaryOverlay.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/22/21.
//

import SwiftUI

struct PrimaryOverlay: View {
	
	private let timer = Timer.publish(every: 5, on: .main, in: .common)
		.autoconnect()
	
	private var buttonText: String {
		get {
			switch self.mapState.travelState {
			case .onBus:
				return "Leave Bus"
			case .notOnBus:
				return "Board Bus"
			}
		}
	}
	
	@EnvironmentObject private var mapState: MapState
	
	@EnvironmentObject private var viewState: ViewState
	
	var body: some View {
		HStack {
			Spacer()
			VStack(alignment: .leading) {
				Button {
					switch self.mapState.travelState {
					case .onBus:
						LocationUtilities.leaveBus()
					case .notOnBus:
						guard let location = LocationUtilities.locationManager.location else {
							break
						}
						let closestStopDistance = self.mapState.stops.reduce(into: Double.greatestFiniteMagnitude) { (distance, stop) in
							let newDistance = stop.location.distance(from: location)
							if newDistance < distance {
								distance = newDistance
							}
						}
						if closestStopDistance < 200 {
							self.mapState.locationID = UUID()
							self.viewState.sheetType = .busSelection
						} else {
							self.viewState.alertType = .noNearbyStop
						}
					}
				} label: {
					Text(self.buttonText)
						.bold()
				}
					.buttonStyle(BlockButtonStyle())
				HStack {
					Text(self.viewState.statusText.rawValue)
						.layoutPriority(1)
					Spacer()
					Button(action: self.refreshBuses) {
						Image(systemName: "arrow.clockwise.circle.fill")
							.resizable()
							.aspectRatio(1, contentMode: .fit)
					}
						.frame(width: 30)
				}
			}
				.padding()
				.background(VisualEffectView(.systemMaterial))
				.cornerRadius(20)
				.shadow(radius: 5)
			Spacer()
		}
			.padding()
			.onReceive(NotificationCenter.default.publisher(for: .refreshBuses, object: nil)) { (_) in
				self.refreshBuses()
			}
			.onReceive(self.timer) { (_) in
				switch self.mapState.travelState {
				case .onBus:
					guard let coordinate = LocationUtilities.locationManager.location?.coordinate else {
						LoggingUtilities.logger.log(level: .info, "User location unavailable")
						break
					}
					LocationUtilities.sendToServer(coordinate: coordinate)
				case .notOnBus:
					break
				}
				self.refreshBuses()
			}
	}
	
	func refreshBuses() {
		[Bus].download { (buses) in
			DispatchQueue.main.async {
				self.mapState.buses = buses
			}
		}
//		if let location = locationManager.location {
//			let locationMapPoint = MKMapPoint(location.coordinate)
//			let nearestStop = self.mapState.stops.min { (firstStop, secondStop) in
//				let firstStopDistance = MKMapPoint(firstStop.coordinate).distance(to: locationMapPoint)
//				let secondStopDistance = MKMapPoint(secondStop.coordinate).distance(to: locationMapPoint)
//				return firstStopDistance < secondStopDistance
//			}
//			let busPoints = self.mapState.buses.map { (bus) -> (bus: Bus, mapPoint: MKMapPoint) in
//
//			}
//			self.statusText = "The next bus is \("?") meters away from the nearest stop."
//		}
	}
	
}

struct PrimaryOverlayPreviews: PreviewProvider {
	
	static var previews: some View {
		PrimaryOverlay()
	}
	
}