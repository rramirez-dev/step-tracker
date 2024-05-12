//
//  Date+Ext.swift
//  Step Tracker
//
//  Created by Robert Ramirez on 5/11/24.
//

import Foundation

extension Date {
  var weekdayInt: Int {
    Calendar.current.component(.weekday, from: self)
  }

  var weekdayTitle: String {
    self.formatted(.dateTime.weekday(.wide))
  }
}
