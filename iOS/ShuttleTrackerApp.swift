//
//  ShuttleTrackerApp.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 9/11/20.
//

import CoreLocation
import OnboardingKit
import SwiftUI

@main
struct ShuttleTrackerApp: App {
	
	@ObservedObject
	private var mapState = MapState.shared
	
	@ObservedObject
	private var viewState = ViewState.shared
	
	@ObservedObject
	private var boardBusManager = BoardBusManager.shared
	
	@ObservedObject
	private var appStorageManager = AppStorageManager.shared
	
	private static let sheetStack = SheetStack()
	
	@UIApplicationDelegateAdaptor(AppDelegate.self)
	private var appDelegate
	
	private let onboardingManager = OnboardingManager(flags: ViewState.shared) { (flags) in
		OnboardingEvent(flags: flags, settingFlagAt: \.toastType, to: .legend) {
			OnboardingConditions.ColdLaunch(threshold: 3)
			OnboardingConditions.ColdLaunch(threshold: 5)
		}
		OnboardingEvent(flags: flags, settingFlagAt: \.legendToastHeadlineText, to: .tip) {
			OnboardingConditions.ColdLaunch(threshold: 3)
		}
		OnboardingEvent(flags: flags, settingFlagAt: \.legendToastHeadlineText, to: .reminder) {
			OnboardingConditions.ColdLaunch(threshold: 5)
		}
		OnboardingEvent(flags: flags, settingFlagAt: \.toastType, to: .boardBus) {
			OnboardingConditions.ManualCounter(defaultsKey: "TripCount", threshold: 0, settingHandleAt: \.tripCount, in: flags.handles)
			OnboardingConditions.Disjunction {
				OnboardingConditions.ColdLaunch(threshold: 5, comparator: >)
				OnboardingConditions.TimeSinceFirstLaunch(threshold: 172800)
			}
		}
		OnboardingEvent(flags: flags, value: SheetStack.SheetType.whatsNew, handler: Self.pushSheet(_:)) {
			OnboardingConditions.ManualCounter(defaultsKey: "WhatsNew1.6", threshold: 0, settingHandleAt: \.whatsNew, in: flags.handles)
			OnboardingConditions.ColdLaunch(threshold: 1, comparator: >)
		}
		OnboardingEvent(flags: flags) { (_) in
			CLLocationManager.registerHandler { (locationManager) in
				switch (locationManager.authorizationStatus, locationManager.accuracyAuthorization) {
				case (.authorizedAlways, .fullAccuracy):
					break
				case (.authorizedWhenInUse, .fullAccuracy):
					ViewState.shared.toastType = .network
				case (.notDetermined, _), (.restricted, _), (.denied, _), (_, .reducedAccuracy):
					Self.pushSheet(.permissions)
				@unknown default:
					fatalError()
				}
			}
		} conditions: {
			OnboardingConditions.ColdLaunch(threshold: 1, comparator: >)
		}
		OnboardingEvent(flags: flags) { (_) in
			if AppStorageManager.shared.maximumStopDistance == 20 {
				AppStorageManager.shared.maximumStopDistance = 50
			}
		} conditions: {
			OnboardingConditions.Once(defaultsKey: "UpdatedMaximumStopDistance")
		}
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(self.mapState)
				.environmentObject(self.viewState)
				.environmentObject(self.boardBusManager)
				.environmentObject(self.appStorageManager)
				.environmentObject(Self.sheetStack)
		}
	}
	
	init() {
		Logging.withLogger { (logger) in
			let formattedVersion: String
			if let version = Bundle.main.version {
				formattedVersion = " \(version)"
			} else {
				formattedVersion = ""
			}
			let formattedBuild: String
			if let build = Bundle.main.build {
				formattedBuild = " (\(build))"
			} else {
				formattedBuild = ""
			}
			logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Shuttle Tracker for iOS\(formattedVersion, privacy: .public)\(formattedBuild, privacy: .public)")
		}
		CLLocationManager.default = CLLocationManager()
		CLLocationManager.default.requestWhenInUseAuthorization()
		CLLocationManager.default.requestAlwaysAuthorization()
		CLLocationManager.default.activityType = .automotiveNavigation
		CLLocationManager.default.showsBackgroundLocationIndicator = true
		CLLocationManager.default.allowsBackgroundLocationUpdates = true
		UIApplication.shared.registerForRemoteNotifications()
		Task {
			do {
				try await UNUserNotificationCenter.requestDefaultAuthorization()
			} catch let error {
				Logging.withLogger(for: .permissions, doUpload: true) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to request notification authorization: \(error, privacy: .public)")
				}
				throw error
			}
		}
	}
	
	private static func pushSheet(_ sheetType: SheetStack.SheetType) {
		Task {
			do {
				if #available(iOS 16, *) {
					try await Task.sleep(for: .seconds(1))
				} else {
					try await Task.sleep(nanoseconds: 1_000_000_000)
				}
			} catch let error {
				Logging.withLogger(doUpload: true) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Task sleep error: \(error, privacy: .public)")
				}
				throw error
			}
			self.sheetStack.push(sheetType)
		}
	}
	
}
