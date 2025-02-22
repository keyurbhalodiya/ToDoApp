//
//  ToDoListView.swift
//  ToDoApp
//
//  Created by Keyur Bhalodiya on 2024/09/17.
//

import SwiftUI
import ComposableArchitecture

final class ModalManager: ObservableObject {
  @Published var isModalPresented: Bool = false
}

struct ToDoListView: View {
  @State private var addTaskViewDetent = PresentationDetent.medium
  @State private var updateTodo: ToDo? = nil
  @ObservedObject private var modalManager = ModalManager()

  let store: StoreOf<ToDoReducer>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      NavigationView {
        ZStack {
          VStack {
            List {
              ForEach(viewStore.todos) { todo in
                TaskRowView(todo: todo) // Task Row
                .listRowInsets(EdgeInsets())
                .contentShape(Rectangle())
                .onTapGesture {
                  updateTodo = todo
                  modalManager.isModalPresented = true
                }
              }
              .onDelete { indexSet in
                for index in indexSet {
                  let todo = viewStore.todos[index]
                  viewStore.send(.deleteTask(id: todo.id))
                }
              }
            }
            .listRowSpacing(10)
            .padding(.vertical, -20)
          }
          FloatingButtonView(updateTodo: $updateTodo, modalManager: modalManager) // Floating Button
        }
        .sheet(isPresented: $modalManager.isModalPresented) {
          ToDoFormView(modal: modalManager, toDo: updateTodo) { todo, isUpdate in // Task Form (Details) view
            if isUpdate {
              viewStore.send(.updateTask(task: todo))
            } else {
              viewStore.send(.addTask(newTask: todo))
            }
          }
          .presentationDetents(
            [.medium, .large],
            selection: $addTaskViewDetent
          )
        }
        .onAppear {
          viewStore.send(.fetchTasks)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .principal) {
            HStack {
              Text("All ToDo")
                .font(.largeTitle)
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.clear)
                .stroke(Color.gray, lineWidth: 1)
                .frame(width: 35, height: 35)
                .overlay(
                  Text("\(viewStore.todos.count)")
                    .foregroundColor(.black)
                    .minimumScaleFactor(0.5)
                    .bold()
                )
              Spacer()
            }
            .padding(.horizontal)
          }
        }
      }
    }
  }
}

#if DEBUG

#Preview {
  ToDoListView(
    store: StoreOf<ToDoReducer>(
      initialState: ToDoReducer.State(
        todos: [ToDo(id: 1, title: "Task 1", status: .todo, deadline: nil, tags: ["study", "education"], createdAt: Date(), updatedAt: Date()),
                ToDo(id: 2, title: "Task 2", status: .inProgress, deadline: nil, tags: ["organization", "education"], createdAt: Date(), updatedAt: Date()),
                ToDo(id: 3, title: "Task 3", status: .done, deadline: nil, tags: ["Swift", "iOS", "SwiftUI", "Combine", "Xcode", "TCA", "MVVM", "CoreData", "SwiftData"], createdAt: Date(), updatedAt: Date())
               ]
      ), reducer: {
        ToDoReducer()
      })
  )
}

#endif
