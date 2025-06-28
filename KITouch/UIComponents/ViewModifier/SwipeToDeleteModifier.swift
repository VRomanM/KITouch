//
//  SwipeToDeleteModifier.swift
//  KITouch
//
//  Created by Alexey Chanov on 27.06.2025.
//

import SwiftUI

struct SimpleSwipeToDeleteModifier: ViewModifier {
    let onDelete: () -> Void
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        ZStack {
            HStack {
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .frame(width: 60, height: 50)
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }

            content
                .background(Color(.systemBackground))
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 {
                                offset = max(value.translation.width, -80)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                if value.translation.width < -50 {
                                    offset = -80
                                } else {
                                    offset = 0
                                }
                            }
                        }
                )
        }
        .clipped()
    }
}
