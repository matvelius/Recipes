//
//  DeviceRotationViewModifier.swift
//  RecipeApp
//
//  Created by Matvey Kostukovsky on 11/3/24.
//

import SwiftUI

// borrowed from https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-device-rotation

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}
