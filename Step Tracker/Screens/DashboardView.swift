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
  @Environment(HealthKitData.self) private var hkData
  @State private var isShowingPermissionPrimingSheet = false
  @State private var selectedStat: HealthMetricContext = .steps
  @State private var isShowingAlert = false
  @State private var fetchError: STError = .noData

  var metricColor: Color {
    selectedStat == .steps ? .pink : .indigo
  }

  var navBarTint: Color {
    if #available(iOS 26.0, *) {
      return .primary
    } else {
      return metricColor
    }
  }

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
            StepBarChart(chartData: ChartHelper.convert(data: hkData.stepData))
            StepPieChart(chartData: ChartHelper.averageWeekdayCount(for: hkData.stepData))
          case .weight:
            WeightLineChart(chartData: ChartHelper.convert(data: hkData.weightData))
            WeightDiffBarChart(chartData: ChartHelper.averageDailyWeightDiffs(for: hkData.weightDiffData))
          }
        }
        .padding()

      }
      .task { fetchHealthData() }
      .navigationTitle("Dashboard")
      .toolbarTitleDisplayMode(.inlineLarge)
      .background(
        LinearGradient(
          colors: [metricColor.opacity(0.25), .clear],
          startPoint: .topLeading,
          endPoint: .bottomTrailing)
      )
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
      .toolbar {
        if #available(iOS 26, *) {
          if DataAnalyzer.shared.model.isAvailable {
            Button("Analyze Data", systemImage: "apple.intelligence") {
              Task { await DataAnalyzer.shared.analyzeHealthData() }
            }
          }
        }
      }
    }
    .tint(navBarTint)
  }

  private func fetchHealthData() {
    Task {
      do {

        // async let will fire off simultaneously
        async let steps = hkManager.fetchStepCount()
        async let weighsForLineChart = hkManager.fetchWeights(daysBack: 28)
        async let weightsForDiffBarChart = hkManager.fetchWeights(daysBack: 29)

        // Update the UI asynchronously
        hkData.stepData = try await steps
        hkData.weightData = try await weighsForLineChart
        hkData.weightDiffData = try await weightsForDiffBarChart
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
    .environment(HealthKitData())
}
