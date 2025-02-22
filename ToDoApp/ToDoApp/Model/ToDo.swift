//
//  ToDo.swift
//  ToDoApp
//
//  Created by Keyur Bhalodiya on 2024/09/17.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class ToDoEntity: Equatable {
  
  var id: Int
  var title: String = ""
  var status: TaskStatus? = nil
  var deadline: String? = nil
  var tags: [String]? = nil
  var createdAt: Date? = nil
  var updatedAt: Date? = nil
  
  init(id: Int, title: String, status: TaskStatus?, deadline: String?, tags: [String]?, createdAt: Date?, updatedAt: Date?) {
    self.id = id
    self.title = title
    self.status = status
    self.deadline = deadline
    self.tags = tags
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

struct APIResponse: Codable {
  var success: Bool
  var data: [ToDo]?
  var totalCount: Int?
  var pageCount: Int?
}

struct AddUpdateTask: Decodable {
  var success: Bool
  var data: ToDo?
}

struct ToDo: Equatable, Identifiable, Codable {
  var id: Int
  var title: String
  var status: TaskStatus?
  var deadline: String?
  var tags: [String]?
  var createdAt: Date?
  var updatedAt: Date?
}

enum TaskStatus: String, Codable, CaseIterable {
  case todo = "todo"
  case inProgress = "inProgress"
  case done = "done"
  
  var title: String {
    switch self {
    case .todo:
      "TODO"
    case .inProgress:
      "IN PROGRESS"
    case .done:
      "DONE"
    }
  }
  
  var backgroundColor: Color {
    switch self {
    case .todo:
      Color(hex: "#FFCC00")
    case .inProgress:
      Color(hex: "#3498DB")
    case .done:
      Color(hex: "#2ECC71")
    }
  }
}
