//
//  ChartDataTypes.swift
//  Step Tracker
//
//  Created by Robert Ramirez on 5/11/24.
//

import Foundation

struct WeekdayChartData: Identifiable {
  let id = UUID()
  let date: Date
  let value: Double
}
