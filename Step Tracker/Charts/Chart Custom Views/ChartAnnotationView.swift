//
//  ChartAnnotationView.swift
//  Step Tracker
//
//  Created by Robert Ramirez on 7/5/24.
//

import Charts
import SwiftUI

struct ChartAnnotationView: ChartContent {
  let data: DateValueChartData
  let context: HealthMetricContext

  var body: some ChartContent {
    RuleMark(x: .value("Selected Metric", data.date, unit: .day))
      .foregroundStyle(Color.secondary.opacity(0.3))
      .offset(y: -10)
      .annotation(
        position: .top,
        alignment: .center,
        spacing: 0,
        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) { annotationView }
  }

  var annotationView: some View {
    VStack(alignment: .leading) {
      Text(
        data.date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
      .font(.footnote.bold())
      .foregroundStyle(Color.secondary)

      Text(data.value, format: .number.precision(.fractionLength(context == .steps ? 0 : 1)))
        .fontWeight(.heavy)
        .foregroundStyle(context == .steps ? .pink : .indigo)
    }
    .padding(12)
    .background(RoundedRectangle(cornerRadius: 4)
      .fill(Color(.secondarySystemGroupedBackground))
      .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
    )
  }
}
