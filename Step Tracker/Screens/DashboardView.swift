//
//  DashboardView.swift
//  Step Tracker
//
//  Created by Robert Ramirez on 4/28/24.
//

import Charts
import SwiftUI

enum HealthMetricContext: CaseIterable, Identifiable {
  case steps, weight
  var id: Self { self }
  
  var title: String {
    switch self {
    case .steps:
      return "Steps"
    case .weight:
      return "Weight"
    }
  }
}
struct DashboardView: View {
  
  @Environment(HealthKitManager.self) private var hkManager
  @State private var isShowingPermissionPrimingSheet = false
  @State private var selectedStat: HealthMetricContext = .steps
  @State private var isShowingAlert = false
  @State private var fetchError: STError = .noData

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          
          Picker("Selected Stat", selection: $selectedStat) {
            ForEach(HealthMetricContext.allCases) {
              Text($0.title)
            }
          }
          .pickerStyle(.segmented)

          switch selectedStat {
          case .steps:
            StepBarChart(chartData: ChartHelper.convert(data: hkManager.stepData))
            StepPieChart(chartData: ChartHelper.averageWeekdayCount(for: hkManager.stepData))
          case .weight:
            WeightLineChart(chartData: ChartHelper.convert(data: hkManager.weightData))
            WeightDiffBarChart(chartData: ChartHelper.averageDailyWeightDiffs(for: hkManager.weightDiffData))
          }
        }
      }
      .padding()
      .task { fetchHealthData() }
      .navigationTitle("Dashboard")
      .navigationDestination(for: HealthMetricContext.self) { metric in
        HealthDataListView(metric: metric)
      }
      .fullScreenCover(isPresented: $isShowingPermissionPrimingSheet, onDismiss: {
        fetchHealthData()
      }, content: {
        HealthKitPermissionPrimingView()
      })
      .alert(isPresented: $isShowingAlert, error: fetchError) { fetchError in
        // Action Button
      } message: { fetchError in
        Text(fetchError.failureReason)
      }
    }
    .tint(selectedStat == .steps ? .pink : .indigo)
  }

  private func fetchHealthData() {
    Task {
      do {

        // async let will fire off simultaneously
        async let steps = hkManager.fetchStepCount()
        async let weighsForLineChart = hkManager.fetchWeights(daysBack: 28)
        async let weightsForDiffBarChart = hkManager.fetchWeights(daysBack: 29)

        // Update the UI asynchronously
        hkManager.stepData = try await steps
        hkManager.weightData = try await weighsForLineChart
        hkManager.weightDiffData = try await weightsForDiffBarChart
        // await hkManager.addSimulatorData()

      } catch STError.authNotDetermined {
        isShowingPermissionPrimingSheet = true
      } catch STError.noData {
        fetchError = .noData
        isShowingAlert = true
      } catch {
        fetchError = .unableToCompleteRequest
        isShowingAlert = true
      }
    }
  }
}

#Preview {
  DashboardView()
    .environment(HealthKitManager())
}
