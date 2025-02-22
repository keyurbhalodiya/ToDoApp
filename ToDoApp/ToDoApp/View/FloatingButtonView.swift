//
//  FloatingButtonView.swift
//  ToDoApp
//
//  Created by Keyur Bhalodiya on 2024/09/23.
//

import Foundation
import SwiftUI

struct FloatingButtonView: View {
  
  @Binding private var updateTodo: ToDo?
  private let modalManager: ModalManager
  
  init(updateTodo: Binding<ToDo?>, modalManager: ModalManager) {
    self._updateTodo = updateTodo
    self.modalManager = modalManager
  }
  
  var body: some View {
    VStack(alignment: .trailing) {
      Spacer()
      HStack {
        Spacer()
        Button(action: {
          updateTodo = nil
          modalManager.isModalPresented = true
        }) {
          HStack {
            Image(systemName: "plus")
              .tint(.black)
          }
          .padding()
          .background(Color.white)
          .mask(Circle())
          .overlay(Circle().stroke(Color.black, lineWidth: 1))
        }
        .frame(width: 60, height: 60)
        Spacer()
          .frame(width: 16)
      }
    }
  }
}
