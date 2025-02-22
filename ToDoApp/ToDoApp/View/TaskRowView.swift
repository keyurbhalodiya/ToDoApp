//
//  TaskRowView.swift
//  ToDoApp
//
//  Created by Keyur Bhalodiya on 2024/09/23.
//

import Foundation
import SwiftUI

struct TaskRowView: View {
  
  private let todo: ToDo
  
  init(todo: ToDo) {
    self.todo = todo
  }
  
  var body: some View {
    ZStack {
      VStack(spacing: 10) {
        HStack {
          Text(todo.title)
            .font(.system(size: 16, weight: .semibold, design: .default))
            .foregroundStyle(Color.primary)
          Spacer()
          
          Text(todo.status?.title ?? "")
            .padding(.all, 4)
            .background(
              Rectangle()
                .fill(todo.status?.backgroundColor ?? Color.blue)
                .cornerRadius(4)
            )
            .foregroundColor(.white)
            .font(.footnote)
        }
        HStack {
          Image(systemName: "calendar.badge.clock")
          Text(todo.createdAt?.dateAndTimeAsString() ?? "")
            .font(.system(size: 14, weight: .medium, design: .default))
            .foregroundStyle(Color.primary)
          Spacer()
        }
        TagView(tags: todo.tags ?? [])
          .padding(.leading, -4)
      }
      .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
      .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
    }
  }
}

#if DEBUG
private struct TaskRowMockView: View {
  
  @State var showView: Bool = true

  var body: some View {
    TaskRowView(todo: ToDo(id: 3, title: "Task 3", status: .done, deadline: nil, tags: ["Swift", "iOS", "SwiftUI", "Combine", "Xcode", "TCA", "MVVM", "CoreData", "SwiftData"], createdAt: Date(), updatedAt: Date()))
  }
}

#Preview {
  TaskRowMockView()
}
#endif
