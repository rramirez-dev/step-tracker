//
//  StepPieChart.swift
//  Step Tracker
//
//  Created by Robert Ramirez on 5/11/24.
//

import Charts
import SwiftUI

struct StepPieChart: View {
  @State private var rawSelectedChartValue: Double? = 0

  var selectedWeekday: WeekdayChartData? {
    guard let rawSelectedChartValue else { return nil }
    var total = 0.0

    return chartData.first {
      total += $0.value
      return rawSelectedChartValue <= total
    }
  }

  var  chartData: [WeekdayChartData]

    var body: some View {
      VStack(alignment: .leading) {
        VStack(alignment:.leading) {
          Label("Averages", systemImage: "calendar")
            .font(.title.bold())
            .foregroundStyle(.pink)

          Text("Last 28 Days")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.bottom, 0) // 12 is the value from the course

        Chart {
          ForEach(chartData) { weekday in
            SectorMark(
              angle: .value("Average Steps", weekday.value),
              innerRadius: .ratio(0.618),
              outerRadius: selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 140 : 110,
              angularInset: 1)
            .foregroundStyle(.pink.gradient)
            .cornerRadius(6)
            .opacity(selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 1.0 : 0.3)
          }
        }
        .chartAngleSelection(value: $rawSelectedChartValue.animation(.easeOut))
        .frame(height: 240)
        .chartBackground { proxy in
          GeometryReader { geo in
            if let plotFrame = proxy.plotFrame {
              let frame = geo[plotFrame]
              if let selectedWeekday {
                VStack {
                  Text(selectedWeekday.date.weekdayTitle)
                    .font(.title3.bold())
                    .contentTransition(.identity) // Figure out how to remove the side to side animation shift

                  Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                }
                .position(x: frame.midX, y: frame.midY)
              }
            }
          }
        }
      }
      .padding()
      .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
  StepPieChart(chartData: ChartMath.averageWeekdayCount(for: HealthMetric.mockData))
}
