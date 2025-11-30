//
//  DataAnalyzer.swift
//  Step Tracker
//
//  Created by Robert Ramirez on 11/29/25.
//

import Foundation
import FoundationModels
import Playgrounds

@available(iOS 26.0, *)
@Observable
final class DataAnalyzer {
  static let shared = DataAnalyzer()
  let model: SystemLanguageModel = .default

  private init() {}
}

// #Playground is a playground for your logic
//@available(iOS 26.0, *)
//#Playground {
//  let session = LanguageModelSession()
//  let prompt = "Show me the notes of the A major scale on a fretboard"
//
//  do {
//    let response = try await session.respond(to: prompt)
//    // print(response.content)
//  } catch {
//    print(error)
//  }
//}
