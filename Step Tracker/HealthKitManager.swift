//
//  HealthKitManager.swift
//  Step Tracker
//
//  Created by Robert Ramirez on 5/6/24.
//

import Foundation
import HealthKit
import Observation

@Observable 
class HealthKitManager {
  let store = HKHealthStore()
  let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
}
