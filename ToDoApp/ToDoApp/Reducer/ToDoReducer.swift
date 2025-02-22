//
//  ToDoReducer.swift
//  ToDoApp
//
//  Created by Keyur Bhalodiya on 2024/09/17.
//

import Foundation
import ComposableArchitecture
import SwiftData

struct ToDoReducer: Reducer {

  struct State: Equatable {
    var todos: [ToDo] = []
  }
  
  enum Action: Equatable {
    case fetchTasks // Trigger to fetch tasks from both API and local
    case fetchTasksResponse([ToDo]) // Response after fetching tasks
    
    case addTask(newTask: ToDo) // Trigger to add a task to API
    case addTaskToLocal(ToDo) // Add task to local storage
    
    case deleteTask(id: Int) // Trigger to delete a task from the API
    case deleteTaskFromLocal(id: Int) // Delete task from local storage
    
    case updateTask(task: ToDo) // Trigger to update a task in the API
    case updateTaskInLocal(task: ToDo) // Update task in local storage
    
    case fetchUpdatedTask(task: ToDo) // Fetch updated task (after an API and local storage update)
  }

  @Dependency(\.toDoEnvironment) var toDoEnvironment
  
  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .fetchTasks:
      return .run { send in
        // Fetch tasks from both API and local storage
        async let apiTasks = toDoEnvironment.fetchRemoteTasks()
        async let localTasks = toDoEnvironment.fetchLocalTasks()
        
        let apiTaskResults = await apiTasks
        let localTaskResults = await localTasks
        
        // Filter out tasks from API that already exist in local storage
        let existingTaskIDs = Set(localTaskResults.map { $0.id })
        let newApiTasks = apiTaskResults.filter { !existingTaskIDs.contains($0.id) }
        
        // Save only new tasks from API to local SwiftData
        for task in newApiTasks {
          let newTodoEntity = ToDoEntity(id: task.id, title: task.title, status: task.status, deadline: task.deadline, tags: task.tags, createdAt: task.createdAt, updatedAt: task.updatedAt)
          await toDoEnvironment.persistLocalTask(newTodoEntity)
        }
        
        // Return local task when API failed or return empty tasks
        let tasks = !apiTaskResults.isEmpty ? apiTaskResults : localTaskResults.map({
          ToDo(id: $0.id, title: $0.title, status: $0.status, deadline: $0.deadline, tags: $0.tags, createdAt: $0.createdAt, updatedAt: $0.updatedAt)
        })
        
        let tasksToReturn = tasks.sorted(by: { $0.id < $1.id })
        await send(.fetchTasksResponse(tasksToReturn))
      }
      
    case let .fetchTasksResponse(todos):
      state.todos = todos
      return .none
      
    case .addTask(let newTask):
      let newTodo = ToDo(id: 0, title: newTask.title, status: newTask.status, deadline: newTask.deadline, tags: newTask.tags, createdAt: newTask.createdAt, updatedAt: newTask.updatedAt)
      return .run { send in
        let newTaskAdded = await toDoEnvironment.createRemoteTask(newTodo)
        guard let newTaskAdded else { return }
        let newTodoEntity = ToDoEntity(id: newTaskAdded.id, title: newTaskAdded.title, status: newTaskAdded.status, deadline: newTaskAdded.deadline, tags: newTaskAdded.tags, createdAt: newTaskAdded.createdAt, updatedAt: newTaskAdded.updatedAt)
        await toDoEnvironment.persistLocalTask(newTodoEntity)
        await send(.addTaskToLocal(newTaskAdded))
      }
      
    case .addTaskToLocal(let newTodo):
      state.todos.append(newTodo)
      return .none
      
    case .deleteTask(let id):
      return .run { send in
        // Delete task from API
        let isSuccess = await toDoEnvironment.removeRemoteTask(id)
        guard isSuccess else { return }
        // Delete task from local storage
        await toDoEnvironment.removeLocalTask(id)
        await send(.deleteTaskFromLocal(id: id))
      }
      
    case .deleteTaskFromLocal(let id):
      // Find the index of the task in the state.todos array
      if let index = state.todos.firstIndex(where: { $0.id == id }) {
        // Remove the task from the state array
        state.todos.remove(at: index)
      }
      return .none
 
    case .updateTask(let task):
      return .run { send in
        let updatedTask = await toDoEnvironment.updateRemoteTask(task)
        await send(.updateTaskInLocal(task: updatedTask))
      }
      
    case .updateTaskInLocal(let updatedTask):
      return .run { send in
        await toDoEnvironment.modifyLocalTask(updatedTask)
        await send(.fetchUpdatedTask(task: updatedTask))
      }
      
    case .fetchUpdatedTask(task: let task):
      // Update task on state.todos after updation on api and local
      if let index = state.todos.firstIndex(where: { $0.id == task.id }) {
        state.todos[index] = task
      }
      return .none
    }
  }
}
