//
//  ToDoEnvironment.swift
//  ToDoApp
//
//  Created by Keyur Bhalodiya on 2024/09/22.
//

import Foundation
import ComposableArchitecture
import SwiftData

struct ToDoEnvironment {
  // Fetch tasks from a remote API
  var fetchRemoteTasks: @Sendable () async -> [ToDo]
  
  // Fetch tasks from local storage
  var fetchLocalTasks: @Sendable () async -> [ToDoEntity]
  
  // Add a task to the remote API
  var createRemoteTask: @Sendable (ToDo) async -> ToDo?
  
  // Save a task to local storage
  var persistLocalTask: @Sendable (ToDoEntity) async -> Void
  
  // Delete a task from the remote API
  var removeRemoteTask: @Sendable (Int) async -> Bool
  
  // Delete a task from local storage
  var removeLocalTask: @Sendable (Int) async -> Void
  
  // Update a task on the remote API
  var updateRemoteTask: @Sendable (ToDo) async -> ToDo
  
  // Update a task in local storage
  var modifyLocalTask: @Sendable (ToDo) async -> Void
}

private enum ToDoEnvironmentKey: DependencyKey {
  static var liveValue: ToDoEnvironment = ToDoEnvironment(
    fetchRemoteTasks: {
      guard let url = URL(string: Constant.bsaeUrl) else {
        return []
      }
      
      do {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
          // In case of a non-200 response, return an empty array
          return []
        }
        
        // Decode the JSON response
        let decodedTasks = try decoder.decode(APIResponse.self, from: data)
        return decodedTasks.data ?? []
      } catch {
        // If any error occurs, return an empty array
        return []
      }
    },
    fetchLocalTasks: {
      // Fetch local tasks from SwiftData
      do {
        let container = try ModelContainer(for: ToDoEntity.self)
        let context = ModelContext(container)
        let todos = try? context.fetch(FetchDescriptor<ToDoEntity>())
        return todos ?? []
      } catch {
        print("Failed to fetch local tasks: \(error)")
      }
      return  []
    },
    createRemoteTask: { task in
      guard let url = URL(string: Constant.bsaeUrl) else { return task }
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      do {
        let jsonData = try encoder.encode(task)
        request.httpBody = jsonData
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else { return task }
        let addedTask = try decoder.decode(AddUpdateTask.self, from: data)
        return addedTask.data
      } catch {
        print("Failed to add task: \(error)")
      }
      return nil
    },
    persistLocalTask: { todoEntity in
      // Save task to SwiftData
      do {
        let container = try ModelContainer(for: ToDoEntity.self)
        let context = ModelContext(container)
        context.insert(todoEntity)
        try context.save()
      } catch {
        print("Failed to save task: \(error)")
      }
    },
    removeRemoteTask: { id in
      guard let url = URL(string: Constant.bsaeUrl + "/\(id)") else { return false }
      var request = URLRequest(url: url)
      request.httpMethod = "DELETE"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      do {
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return false }
        return true
      } catch {
        print("Failed to delete task: \(error)")
      }
      return false
    },
    removeLocalTask: { id in
      do {
        let container = try ModelContainer(for: ToDoEntity.self)
        let context = ModelContext(container)
        let fetchDescriptor = FetchDescriptor<ToDoEntity>(predicate: #Predicate { $0.id == id })
        if let todoEntity = try context.fetch(fetchDescriptor).first {
          context.delete(todoEntity)
          try context.save()
        } else {
          print("Task with id \(id) not found")
        }
      } catch {
        print("Failed to delete task: \(error)")
      }
    },
    updateRemoteTask: { task in
      guard let url = URL(string: Constant.bsaeUrl + "/\(task.id)") else { return task }
      var request = URLRequest(url: url)
      request.httpMethod = "PUT"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      do {
        let jsonData = try encoder.encode(task)
        request.httpBody = jsonData
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return task }
        let updateTask = try decoder.decode(AddUpdateTask.self, from: data)
        return updateTask.data ?? task
      } catch {
        print("Failed to update task: \(error)")
      }
      return task
    },
    modifyLocalTask: { task in
      do {
        let container = try ModelContainer(for: ToDoEntity.self)
        let context = ModelContext(container)
        let fetchDescriptor = FetchDescriptor<ToDoEntity>(predicate: #Predicate { $0.id == task.id })
        if let todoEntity = try context.fetch(fetchDescriptor).first {
          todoEntity.title = task.title
          todoEntity.status = task.status
          todoEntity.tags = task.tags
          todoEntity.updatedAt = task.updatedAt
          try context.save()
        } else {
          print("Task with id \(task.id) not found")
        }
      } catch {
        print("Failed to delete task: \(error)")
      }
    }
  )
  
  private static var decoder: JSONDecoder {
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = Constant.dateFormatter
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    return decoder
  }
  
  private static var encoder: JSONEncoder {
    let encoder = JSONEncoder()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = Constant.dateFormatter
    encoder.dateEncodingStrategy = .formatted(dateFormatter)
    return encoder
  }
}

extension DependencyValues {
  var toDoEnvironment: ToDoEnvironment {
    get { self[ToDoEnvironmentKey.self] }
    set { self[ToDoEnvironmentKey.self] = newValue }
  }
}

