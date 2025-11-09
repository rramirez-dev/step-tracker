//
//  HealthDataListView.swift
//  Step Tracker
//
//  Created by Robert Ramirez on 4/30/24.
//

import SwiftUI

struct ExportOption: Identifiable, Hashable {
  let id = UUID()
  let name: String
}

struct HealthDataListView: View {

  @Environment(HealthKitManager.self) private var hkManager
  @State private var isShowingAddData = false
  @State private var isShowingExportOptions = false
  @State private var addDataDate: Date = .now
  @State private var valueToAdd: String = ""
  @State private var isShowingAlert = false
  @State private var writeError: STError = STError.noData
  @State private var selection: ExportType?
  @State private var editMode: EditMode = .active
  @State private var exportedCsvData: URL?

  var metric: HealthMetricContext

  var listData: [HealthMetric] {
    metric == .steps ? hkManager.stepData : hkManager.weightData
  }

  var body: some View {
    List(listData.reversed()) { data in
      LabeledContent {
        Text(data.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 1)))
      } label: {
        Text(data.date, format: .dateTime.month().day().year())
          .accessibilityLabel(data.date.accessibilityDate)
      }
      .accessibilityElement(children: .combine)
    }
    .navigationTitle(metric.title)
    .sheet(isPresented: $isShowingAddData) {
      addDataView
    }
    .sheet(isPresented: $isShowingExportOptions) {
      exportOptionsView
    }
    .toolbar {
      Button("Export", systemImage: "square.and.arrow.up") {
        isShowingExportOptions = true
      }
      Button("Add Data", systemImage: "plus") {
        isShowingAddData = true
      }
    }
  }

  // Use variable views for simple views that are not reused
  var addDataView: some View {
    NavigationStack {
      Form {
        DatePicker("Date", selection: $addDataDate, displayedComponents: .date)
        LabeledContent(metric.title) {
          TextField("Value", text: $valueToAdd)
            .multilineTextAlignment(.trailing)
            .frame(width: 140)
            .keyboardType(metric == .steps ? .numberPad : .decimalPad)
        }
      }
      .navigationTitle(metric.title)
      .alert(isPresented: $isShowingAlert, error: writeError) { writeError in
        switch writeError {
        case .authNotDetermined, .noData, .unableToCompleteRequest, .invalidValue:
          EmptyView()
        case .sharingDenied(_):
          Button("Settings") {
            // Deep Link
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
          }
          Button("Cancel", role: .cancel) {}
        }
      } message: { writeError in
        Text(writeError.failureReason)
      }
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Add Data") {
            addDataToHealthKit()
          }
        }

        ToolbarItem(placement: .topBarLeading) {
          Button("Dismiss") {
            isShowingAddData = false
          }
        }

      }
    }
  }

  var exportOptionsView: some View {
    NavigationStack {
      VStack {
        List( selection: $selection) {
          ForEach(ExportType.allCases, id: \.self) { exportType in
            Text(exportType.rawValue)
              // .listRowBackground(Color.clear)
          }
        }
        .environment(\.editMode, $editMode)
        .listStyle(.plain)
        .padding(.top, 5)
        .padding(.leading, 18)
        .padding(.trailing, 18)
        .navigationTitle("Export \(metric == .steps ? "Steps" : "Weight") Data to")
        Spacer()
        if let exportedCsvData {
          ShareLink(item: exportedCsvData) {
            Text("Share Data")
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Export") {
            if let selectedOption = selection {
              exportedCsvData = hkManager.exportData(for: metric, to: selectedOption)
            }
            // isShowingExportOptions = false
          }
        }

        ToolbarItem(placement: .topBarLeading) {
          Button("Dismiss") {
            isShowingExportOptions = false
          }
        }
      }
    }
  }

  private func addDataToHealthKit() {
    guard let value = Double(valueToAdd) else {
      writeError = .invalidValue
      isShowingAlert = true
      valueToAdd = ""
      return
    }
    Task {
      do {
        if metric == .steps {
          try await hkManager.addStepData(for: addDataDate, value: value)
          hkManager.stepData = try await hkManager.fetchStepCount()
        } else {
          try await hkManager.addWeightData(for: addDataDate, value: value)
          // Challenge: Find a solution that allows you to fetch the same data with a single call
          async let weighsForLineChart = hkManager.fetchWeights(daysBack: 28)
          async let weightsForDiffBarChart = hkManager.fetchWeights(daysBack: 29)

          hkManager.weightData = try await weighsForLineChart
          hkManager.weightDiffData = try await weightsForDiffBarChart
        }
        isShowingAddData = false
      } catch STError.sharingDenied( let quantityType) {
        writeError = .sharingDenied(quantityType: quantityType)
        isShowingAlert = true
      } catch {
        writeError = .unableToCompleteRequest
        isShowingAlert = true
      }
    }
  }
}

#Preview {
  NavigationStack {
    HealthDataListView(metric: .weight)
      .environment(HealthKitManager())
  }
}
