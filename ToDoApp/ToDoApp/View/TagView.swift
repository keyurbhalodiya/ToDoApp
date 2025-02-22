//
//  TagView.swift
//  ToDoApp
//
//  Created by Keyur Bhalodiya on 2024/09/19.
//

import SwiftUI

struct Tag: Identifiable, Equatable {
  let id = UUID()
  let name: String
}

struct TagView: View {
  
  private let tags: [Tag]
  @State private var totalHeight = CGFloat.zero  // Tracks total height of the tag container base on tags
  
  init(tags: [String]) {
    self.tags = tags.map({ Tag(name: $0) })
  }
  
  var body: some View {
    VStack {
      GeometryReader { geometry in
        self.generateTags(in: geometry.size)
      }
    }
    .frame(height: totalHeight)  // Adjust the frame height to fit the content
  }
  
  private func generateTags(in size: CGSize) -> some View {
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    return ZStack(alignment: .topLeading) {
      ForEach(tags) { tag in
        self.tagView(for: tag)
          .padding([.horizontal, .vertical], 4)
          .alignmentGuide(.leading) { dimension in
            if (abs(width - dimension.width) > size.width) {
              width = 0
              height -= dimension.height
            }
            let result = width
            if tag == self.tags.last! {
              width = 0  // Reset width for the next line
            } else {
              width -= dimension.width
            }
            return result
          }
          .alignmentGuide(.top) { _ in
            let result = height
            if tag == self.tags.last! {
              height = 0  // Reset height for the next row
            }
            return result
          }
      }
    }
    .background(viewHeightReader($totalHeight))  // Reads the total height of the view
  }
  
  private func tagView(for tag: Tag) -> some View {
    Text(tag.name)
      .font(.system(size: 12, weight: .medium, design: .default))
      .padding(.vertical, 8)
      .padding(.horizontal, 8)
      .background(Color.blue.opacity(0.2))
      .cornerRadius(10)
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Color.clear, lineWidth: 0)
      )
  }
  
  private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
    return GeometryReader { geometry -> Color in
      DispatchQueue.main.async {
        binding.wrappedValue = geometry.size.height
      }
      return Color.clear
    }
  }
}

struct TagView_Previews: PreviewProvider {
  static var previews: some View {
    TagView(tags: ["Swift", "iOS", "SwiftUI", "Combine", "Xcode", "TCA", "MVVM", "CoreData", "SwiftData"])
      .padding()
  }
}
