//
//  TextEditorWithPlaceholder.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 14/02/2025.
//

import SwiftUI

struct TextEditorWithPlaceholder: View {
    @Binding var text: String
    var placeholder: String = ""
    var body: some View {
        ZStack {
            TextEditor(text: $text)
            
            if text.isEmpty {
                VStack {
                    HStack {
                        Text(placeholder)
                            .foregroundStyle(.tertiary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

//#Preview {
//    TextEditorWithPlaceholder()
//}
