//
//  ChartDataTypes.swift
//  Step Tracker
//
//  Created by Robert Ramirez on 5/11/24.
//

import Foundation

struct DateValueChartData: Identifiable, Equatable {
  let id = UUID()
  let date: Date
  let value: Double
}
