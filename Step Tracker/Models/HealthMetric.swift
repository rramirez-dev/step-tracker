//
//  HealthMetric.swift
//  Step Tracker
//
//  Created by Robert Ramirez on 5/9/24.
//

import Foundation

struct HealthMetric: Identifiable {
  let id = UUID()
  let date: Date
  let value: Double
}
