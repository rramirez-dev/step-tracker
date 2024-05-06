//
//  HealthKitPermissionPrimingView.swift
//  Step Tracker
//
//  Created by Robert Ramirez on 5/5/24.
//

import SwiftUI

struct HealthKitPermissionPrimingView: View {
  var description = """
  This app displays your step and weight data in interactive charts.

  You can also add new step and weight data to Apple Health from this app. Your data is private and secured.
  """

  var body: some View {
    VStack(spacing: 130) {
      VStack(alignment: .leading, spacing: 10) {
        Image(.appleHealth)
          .resizable()
          .frame(width: 90, height: 90)
          .shadow(color: .gray.opacity(0.3), radius: 16)
          .padding(.bottom, 12)

        Text("Apple Health Intergration")
          .font(.title2).bold()

        Text(description)
          .foregroundStyle(.secondary)
      }

      Button("Connect Apple Health") {
        // Do code later
      }
      .buttonStyle(.borderedProminent)
      .tint(.pink)
    }
    .padding(30)
  }
}

#Preview {
  HealthKitPermissionPrimingView()
}
