//
//  ToDoFormView.swift
//  ToDoApp
//
//  Created by Keyur Bhalodiya on 2024/09/19.
//

import SwiftUI

struct ToDoFormView: View {
  
  @ObservedObject private var modalManager: ModalManager
  
  @State private var title: String = ""
  @State private var status: TaskStatus = .todo
  @State private var tags: String = ""
  @State private var selectedTime: Date = Date.now
  @State private var showingAlert = false
  private var toDo: ToDo?
  
  private let statusOptions = TaskStatus.allCases
  private let isUpdate: Bool
  var didTappedSave: (ToDo, Bool) -> Void

  init(modal: ModalManager, toDo: ToDo?, callBack: @escaping (ToDo, Bool) -> Void) {
    modalManager = modal
    self.toDo = toDo
    title = toDo?.title ?? ""
    status = toDo?.status ?? .todo
    tags = toDo?.tags?.joined(separator: " ") ?? ""
    selectedTime = toDo?.createdAt ?? Date.now
    isUpdate = toDo != nil
    didTappedSave = callBack
  }
  
  var body: some View {
    NavigationView {
      Form {
        Section() {
          TextField("Enter title", text: $title)
          HStack() {
            Image(systemName: "calendar.badge.clock")
            DatePicker("Due to", selection: $selectedTime)
              .foregroundStyle(Color(UIColor.lightGray))
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        Section() {
          Picker("Select status", selection: $status) {
            ForEach(statusOptions, id: \.self) {
              Text($0.title)
            }
          }
          .pickerStyle(SegmentedPickerStyle())
          TextField("Enter tags", text: $tags)
            .textInputAutocapitalization(.words)
        }
      }
      .navigationTitle(isUpdate ? "Update ToDo" : "Add ToDo")
      .navigationBarItems(leading: Button("Cancel") {
        modalManager.isModalPresented = false
      }, trailing: Button(isUpdate ? "Update" : "Save") {
        guard !title.isEmpty else {
          showingAlert = true
          return
        }
        modalManager.isModalPresented = false
        didTappedSave(ToDo(id: toDo?.id ?? 0, title: title, status: status, tags: tags.components(separatedBy: " ").filter({ !$0.isEmpty }), createdAt: selectedTime, updatedAt: Date.now), isUpdate)
      })
    }
    .alert("Please enter title", isPresented: $showingAlert) {
      Button("OK", role: .cancel) { }
    }
  }
}

#if DEBUG
private struct ToDoFormMockView: View {
  
  @State var showView: Bool = true

  var body: some View {
    ToDoFormView(modal: ModalManager(), toDo: nil, callBack: { _,_  in })
  }
}

#Preview {
  ToDoFormMockView()
}
#endif

