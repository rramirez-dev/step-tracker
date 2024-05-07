//
//  Step_TrackerApp.swift
//  Step Tracker
//
//  Created by Robert Ramirez on 4/28/24.
//

import SwiftUI

@main
struct Step_TrackerApp: App {

  let hkManager = HealthKitManager()

  var body: some Scene {
    WindowGroup {
      DashboardView()
        .environment(hkManager)
    }
  }
}
