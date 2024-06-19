//
//  HealthDataListView.swift
//  Step Tracker
//
//  Created by Robert Ramirez on 4/30/24.
//

import SwiftUI

struct HealthDataListView: View {

  @Environment(HealthKitManager.self) private var hkManager
  @State private var isShowingAddData = false
  @State private var addDataDate: Date = .now
  @State private var valueToAdd: String = ""
  @State private var isShowingAlert = false
  @State private var writeError: STError = STError.noData

  var metric: HealthMetricContext

  var listData: [HealthMetric] {
    metric == .steps ? hkManager.stepData : hkManager.weightData
  }

  var body: some View {
    List(listData.reversed()) { data in
      HStack {
        Text(data.date, format: .dateTime.month().day().year())
        Spacer()
        Text(data.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 1)))
      }
    }
    .navigationTitle(metric.title)
    .sheet(isPresented: $isShowingAddData) {
      addDataView
    }
    .toolbar {
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
        HStack {
          Text(metric.title)
          Spacer()
          TextField("Value", text: $valueToAdd)
            .multilineTextAlignment(.trailing)
            .frame(width: 140)
            .keyboardType(metric == .steps ? .numberPad : .decimalPad)
        }
      }
      .navigationTitle(metric.title)
      .alert(isPresented: $isShowingAlert, error: writeError) { writeError in
        switch writeError {
        case .authNotDetermined, .noData, .unableToCompleteRequest:
          EmptyView()
        case .sharingDenied(let quantityType):
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
            Task {
              if metric == .steps {
                do {
                  try await hkManager.addStepData(for: addDataDate, value: Double(valueToAdd)!)
                  try await hkManager.fetchStepCount()
                  isShowingAddData = false
                } catch STError.sharingDenied( let quantityType) {
                  writeError = .sharingDenied(quantityType: quantityType)
                  isShowingAlert = true
                } catch {
                  writeError = .unableToCompleteRequest
                  isShowingAlert = true
                }
              } else {
                do {
                  try await hkManager.addWeightData(for: addDataDate, value: Double(valueToAdd)!)
                  try await hkManager.fetchWeights()
                  try await hkManager.fetchWeightsForDifferentials()
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
        }

        ToolbarItem(placement: .topBarLeading) {
          Button("Dismiss") {
            isShowingAddData = false
          }
        }

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
