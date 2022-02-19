//
//  PrivacySheet.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 8/30/21.
//

import SwiftUI

struct PrivacySheet: View {
	
	@EnvironmentObject private var viewState: ViewState
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Spacer()
				Text("Welcome to Shuttle Tracker!")
					.font(.largeTitle)
					.bold()
					.multilineTextAlignment(.center)
				Spacer()
			}
			.padding(.bottom)
			Text("Shuttle Tracker shows you the real-time locations of the RPI campus shuttles, powered by crowd-sourced location data.")
				.padding(.bottom)
			Text("Privacy")
				.font(.headline)
			Text("Shuttle Tracker sends your location data to our server only when you tap “Board Bus” and stops sending these data when you tap “Leave Bus”. Your location data are associated with an anonymous, random identifier that rotates every time you start a new shuttle trip. These data aren’t associated with your name, Apple ID, RCS ID, or any other identifying information. We continuously purge location data that are more than 30 seconds old from our server. We may retain resolved location data that are calculated using a combination of system- and user-reported data indefinitely, but these resolved data don’t correspond with any specific user-reported coordinates.")
			Spacer()
			Button {
				self.viewState.sheetType = nil
			} label: {
				Text("Continue")
					.bold()
			}
				.buttonStyle(.block)
		}
			.padding()
	}
	
}

struct PrivacySheetPreviews: PreviewProvider {
	
	static var previews: some View {
		PrivacySheet()
	}
	
}
