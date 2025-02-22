//
//  ToDoAppApp.swift
//  ToDoApp
//
//  Created by Keyur Bhalodiya on 2024/09/17.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

@main
struct ToDoAppApp: App {
  
  private let modelContainer: ModelContainer
  
  init() {
    do {
      modelContainer = try ModelContainer(for: ToDoEntity.self)
    } catch {
      fatalError("Could not initialize ModelContainer")
    }
  }
  
  var body: some Scene {
    WindowGroup {
      ToDoListView(
        store: StoreOf<ToDoReducer>(
          initialState: ToDoReducer.State(), reducer: {
            ToDoReducer()
          }
        )
      )
    }
  }
}
