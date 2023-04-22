//
//  AnnouncementDetailView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/20/21.
//

import SwiftUI

struct AnnouncementDetailView: View {
	
	@Binding
	private(set) var didResetViewedAnnouncements: Bool
	
	@EnvironmentObject
	private var appStorageManager: AppStorageManager
	
	let announcement: Announcement
	
	var body: some View {
		ScrollView {
            VStack {
                #if os(macOS)
                HStack {
                    Text(self.announcement.subject)
                        .font(.headline)
                    Spacer()
                }
                .padding(.top)
                #endif // os(macOS)
                HStack {
                    Text(self.announcement.body)
                    Spacer()
                }
                HStack {
                    switch self.announcement.scheduleType {
                    case .none:
                        EmptyView()
                    case .startOnly:
                        Text("Posted \(self.announcement.startString)")
                    case .endOnly:
                        Text("Expires \(self.announcement.endString)")
                    case .startAndEnd:
                        Text("Posted \(self.announcement.startString); expires \(self.announcement.endString)")
                    }
                    Spacer()
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
                .padding()
                .background(.thinMaterial)
                .cornerRadius(20)
		}
			.padding(.horizontal)
			.frame(minWidth: 300)
			.navigationTitle(self.announcement.subject)
			.toolbar {
				#if os(iOS)
				ToolbarItem {
					CloseButton()
				}
				#endif // os(iOS)
			}
			.task {
				self.didResetViewedAnnouncements = false
				self.appStorageManager.viewedAnnouncementIDs.insert(self.announcement.id)
				
				do {
					try await Analytics.upload(eventType: .announcementViewed(id: self.announcement.id))
				} catch let error {
					Logging.withLogger(for: .api) { (logger) in
						logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to upload analytics entry: \(error, privacy: .public)")
					}
				}
			}
	}
	
}
