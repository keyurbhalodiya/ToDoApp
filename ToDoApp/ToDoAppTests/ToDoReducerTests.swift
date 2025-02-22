//
//  ToDoReducerTests.swift
//  ToDoAppTests
//
//  Created by Keyur Bhalodiya on 2024/09/24.
//

import XCTest
import ComposableArchitecture
@testable import ToDoApp

final class ToDoReducerTests: XCTestCase {
  
  private enum Constant {
    static let mockAPIResponse = [
      ToDo(id: 1, title: "API Task 1", status: .todo, deadline: nil, tags: [], createdAt: Date(), updatedAt: Date()),
      ToDo(id: 2, title: "API Task 2", status: .inProgress, deadline: nil, tags: [], createdAt: Date(), updatedAt: Date())
    ]
    static let mockTask = ToDo(id: 0, title: "Mock Task", status: .inProgress, deadline: nil, tags: [], createdAt: Date(), updatedAt: Date())
  }

  @MainActor
  func testFetchTasksSuccess() async {
    // Mock the ToDo environment with sample API response
    let environment = ToDoEnvironment(
      fetchRemoteTasks: {
        Constant.mockAPIResponse
      },
      fetchLocalTasks: {
        []
      },
      createRemoteTask: { _ in nil },
      persistLocalTask: { _ in },
      removeRemoteTask: { _ in false },
      removeLocalTask: { _ in },
      updateRemoteTask: { _ in Constant.mockTask },
      modifyLocalTask: { _ in }
    )
    
    // Create a TestStore with the mocked environment
    let store = TestStoreOf<ToDoReducer>(
      initialState: ToDoReducer.State(),
      reducer: {
        ToDoReducer()
      }
    ) {
      // Inject the custom `ToDoEnvironment` for testing purposes
      $0.toDoEnvironment = environment
    }
    
    // Send action to fetch tasks
    await store.send(.fetchTasks)
    // Expect the state to update with the mock API response
    await store.receive(.fetchTasksResponse(Constant.mockAPIResponse)) { state in
      state.todos = Constant.mockAPIResponse
    }
    
    XCTAssertEqual(store.state.todos.count, 2, "The todos array should contain 2 tasks")
  }
  
  @MainActor
  func testAddTaskSuccess() async {
    let newTask = ToDo(id: 3, title: "New Task", status: .todo, deadline: nil, tags: [], createdAt: Date(), updatedAt: Date())
    let addedTaskEntity = ToDoEntity(id: 3, title: "New Task", status: .todo, deadline: nil, tags: [], createdAt: Date(), updatedAt: Date())
    
    let environment = ToDoEnvironment(
      fetchRemoteTasks: { [] },
      fetchLocalTasks: { [] },
      createRemoteTask: { _ in newTask },
      persistLocalTask: { _ in },
      removeRemoteTask: { _ in false },
      removeLocalTask: { _ in },
      updateRemoteTask: { _ in Constant.mockTask },
      modifyLocalTask: { _ in }
    )
    
    let store = TestStoreOf<ToDoReducer>(
      initialState: ToDoReducer.State(todos: Constant.mockAPIResponse),
      reducer: {
        ToDoReducer()
      }
    ) {
      $0.toDoEnvironment = environment
    }
    
    // Test adding a new task
    await store.send(.addTask(newTask: newTask))
    await store.receive(.addTaskToLocal(newTask)) { state in
      state.todos.append(newTask)
    }
    
    XCTAssertEqual(store.state.todos.count, 3, "The todos array should contain 3 tasks after adding new")
  }
  
  @MainActor
  func testDeleteTaskSuccess() async {
    let environment = ToDoEnvironment(
      fetchRemoteTasks: { [] },
      fetchLocalTasks: { [] },
      createRemoteTask: { _ in nil },
      persistLocalTask: { _ in },
      removeRemoteTask: { _ in true },
      removeLocalTask: { _ in },
      updateRemoteTask: { _ in Constant.mockTask },
      modifyLocalTask: { _ in }
    )
    
    let store = TestStoreOf<ToDoReducer>(
      initialState: ToDoReducer.State(todos: Constant.mockAPIResponse),
      reducer: {
        ToDoReducer()
      }
    ) {
      $0.toDoEnvironment = environment
    }
    
    // Test deleting a task
    await store.send(.deleteTask(id: 1))
    await store.receive(.deleteTaskFromLocal(id: 1)) { state in
      state.todos.remove(at: 0)
    }
    
    XCTAssertEqual(store.state.todos.count, 1, "The todos array should contain 1 tasks after delete one task")
  }
  
  @MainActor
  func testUpdateTaskSuccess() async {
    let initialTask = ToDo(id: 1, title: "Old Task", status: .todo, deadline: nil, tags: [], createdAt: Date(), updatedAt: Date())
    let updatedTask = ToDo(id: 1, title: "Updated Task", status: .inProgress, deadline: nil, tags: [], createdAt: Date(), updatedAt: Date())
    
    let environment = ToDoEnvironment(
      fetchRemoteTasks: { [] },
      fetchLocalTasks: { [] },
      createRemoteTask: { _ in nil },
      persistLocalTask: { _ in },
      removeRemoteTask: { _ in false },
      removeLocalTask: { _ in },
      updateRemoteTask: { _ in updatedTask },
      modifyLocalTask: { _ in }
    )
    
    let store = TestStoreOf<ToDoReducer>(
      initialState: ToDoReducer.State(todos: [initialTask]),
      reducer: {
        ToDoReducer()
      }
    ) {
      $0.toDoEnvironment = environment
    }
    
    // Test updating a task
    await store.send(.updateTask(task: initialTask))
    await store.receive(.updateTaskInLocal(task: updatedTask))
    await store.receive(.fetchUpdatedTask(task: updatedTask)) { state in
      state.todos[0] = updatedTask
    }
    
    XCTAssertEqual(store.state.todos.first?.status, .inProgress, "Task status should update to inProgress")
  }
}

